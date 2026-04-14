import assert from 'node:assert/strict';
import test from 'node:test';

import { handleMedicineAiDetail } from './medicine-ai-detail';
import { handleMedicineAiSafety } from './medicine-ai-safety';

test('medicine ai detail handler forwards refresh=true to cache loader', async () => {
  let capturedRefresh = false;

  const result = await handleMedicineAiDetail(
    { drugCode: 'D123', refresh: true },
    {
      findMedicine: async () => ({
        serialNo: '',
        approvalNo: 'H123',
        productName: '阿莫西林',
        dosageForm: '',
        specification: '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: 'D123',
        drugCodeRemark: '',
      }),
      buildPrompt: () => 'detail-prompt',
      callTextModel: async () => 'detail-text',
      buildCacheKey: () => 'ai:detail:v1:D123',
      loadAiTextWithCache: async ({ refresh, generate }) => {
        capturedRefresh = refresh;
        return {
          text: await generate(),
          source: 'generated',
          cachedAt: '2026-04-14T10:00:00.000Z',
          expiresAt: '2026-04-21T10:00:00.000Z',
        };
      },
    },
  );

  assert.equal(result.code, '1');
  assert.equal(capturedRefresh, true);
  assert.equal(result.result?.text, 'detail-text');
});

test('medicine ai safety handler builds cache request for pair mode', async () => {
  let capturedKey = '';
  let capturedRefresh = false;

  const result = await handleMedicineAiSafety(
    {
      mode: 'pair',
      refresh: false,
      medicines: [
        { approvalNo: 'B-002', productName: '乙药' },
        { drugCode: 'A-001', productName: '甲药' },
      ],
    },
    {
      findMedicine: async (input) => ({
        serialNo: '',
        approvalNo: input.approvalNo ?? '',
        productName: input.productName ?? '',
        dosageForm: '',
        specification: '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: input.drugCode ?? '',
        drugCodeRemark: '',
      }),
      buildPrompt: () => 'safety-prompt',
      callTextModel: async () => 'safety-text',
      loadAiTextWithCache: async ({ key, refresh, generate }) => {
        capturedKey = key ?? '';
        capturedRefresh = refresh;
        return {
          text: await generate(),
          source: 'generated',
          cachedAt: '2026-04-14T11:00:00.000Z',
          expiresAt: '2026-04-21T11:00:00.000Z',
        };
      },
    },
  );

  assert.equal(result.code, '1');
  assert.equal(capturedRefresh, false);
  assert.equal(capturedKey, 'ai:safety:v1:pair:A-001:B-002');
  assert.equal(result.result?.text, 'safety-text');
});
