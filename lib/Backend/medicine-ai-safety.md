访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-ai-safety
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-ai-safety

用途:
- 安全辅助:
  - 单药: 查询用药建议、注意事项、特殊人群提示
  - 双药: 查询两种药是否有相互作用/联合用药建议

请求体:
- userId: string (可选)
- mode: 'single' | 'pair'
- medicines: MedicineRef[] (single=1个，pair=2个)

MedicineRef 字段:
- drugCode: string
- approvalNo: string
- productName: string

返回体:
- code: string
- msg: string
- result: { text: string }

说明:
- 推荐后端先用 drugCode/approvalNo 查询基础信息，再拼 prompt 调腾讯云 `GetLLMDiagnosisDrugChat`
- 输出先用 text，后续可升级为 sections JSON，前端更好排版

参考接口文档:
- GetLLMDiagnosisDrugChat: https://cloud.tencent.com/document/product/1273/128048

```typescript
import { Client } from 'tencentcloud-sdk-nodejs-ig'

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

function mustEnv(name: string) {
  const v = String(process.env[name] || '').trim()
  if (!v) throw new Error(`缺少环境变量: ${name}`)
  return v
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const mode = String((ctx.body as any).mode || 'single').trim()
  const medicines = Array.isArray((ctx.body as any).medicines)
    ? (ctx.body as any).medicines
    : []

  if (!['single', 'pair'].includes(mode)) {
    return fail('mode 必须是 single 或 pair')
  }

  if (mode === 'single' && medicines.length !== 1) {
    return fail('single 模式 medicines 必须为 1 个')
  }
  if (mode === 'pair' && medicines.length !== 2) {
    return fail('pair 模式 medicines 必须为 2 个')
  }

  const ig = new Client({
    credential: {
      secretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
      secretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
    },
    region: mustEnv('TENCENTCLOUD_REGION'),
    profile: { httpProfile: { endpoint: 'ig.tencentcloudapi.com' } },
  })

  const prompt =
    mode === 'pair'
      ? [
          '你是一名药学问答助手，请评估以下两种药物是否存在相互作用，并给出中文建议。',
          `药品A: ${JSON.stringify(medicines[0])}`,
          `药品B: ${JSON.stringify(medicines[1])}`,
          '请输出：是否存在相互作用、可能风险、联用建议、什么情况下需要咨询医生或药师。',
          '输出纯文本，不要输出 markdown 代码块。',
        ].join('\n')
      : [
          '你是一名药学问答助手，请根据以下药物信息返回中文用药建议。',
          `药品: ${JSON.stringify(medicines[0])}`,
          '请输出：常见用途、禁忌/慎用人群、注意事项、什么情况下需要咨询医生或药师。',
          '输出纯文本，不要输出 markdown 代码块。',
        ].join('\n')

  const resp = await ig.GetLLMDiagnosisDrugChat({
    PartnerId: mustEnv('IG_PARTNER_ID'),
    PartnerSecret: mustEnv('IG_PARTNER_SECRET'),
    HospitalAppId: mustEnv('IG_HOSPITAL_APP_ID'),
    DialogueId: `${Date.now()}`,
    ResultType: 0,
    Message: prompt,
  })

  return success({
    text: String(resp?.Data?.Content || '').trim(),
  })
}
```
