访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-ai-detail
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-ai-detail

用途:
- 药品详情页: 点击“获取详细信息”后，由后端调用「腾讯云 智能导诊-大模型问药」生成更详细解读并返回

请求体(二选一即可，推荐 drugCode):
- drugCode: string
- approvalNo: string

返回体:
- code: string
- msg: string
- result:
  - text: string

说明:
- 后端建议先查 MySQL 基础信息（产品名/剂型/规格/厂家等），再拼接 prompt 调用腾讯云 `GetLLMDiagnosisDrugChat`
- 该接口输出仍为 text（前端现阶段按纯文本展示）

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

  const drugCode = String((ctx.body as any).drugCode || '').trim()
  const approvalNo = String((ctx.body as any).approvalNo || '').trim()
  if (!drugCode && !approvalNo) {
    return fail('drugCode 或 approvalNo 不能为空')
  }

  // TODO: 复用现有 /medicine-detail 的 MySQL 查询逻辑，得到基础信息 detail
  const detail = {
    productName: '示例药品',
    dosageForm: '片剂',
    specification: '0.5g*20片',
    manufacturer: '示例制药',
    approvalNo,
    drugCode,
  }

  const ig = new Client({
    credential: {
      secretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
      secretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
    },
    region: mustEnv('TENCENTCLOUD_REGION'),
    profile: { httpProfile: { endpoint: 'ig.tencentcloudapi.com' } },
  })

  const prompt = [
    '你是一名药学问答助手，请根据以下药品基础信息返回中文说明。',
    `产品名称: ${detail.productName}`,
    `剂型: ${detail.dosageForm}`,
    `规格: ${detail.specification}`,
    `生产单位: ${detail.manufacturer}`,
    `批准文号: ${detail.approvalNo}`,
    `药品编码: ${detail.drugCode}`,
    '请分点说明：适应症、常见用法用量提示、常见不良反应、禁忌、注意事项、特殊人群提示。',
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
