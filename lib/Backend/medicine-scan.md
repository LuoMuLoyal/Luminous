访问地址: https://wty10hv6az.sealosbja.site
函数路径: POST /medicine-scan
公网访问路径: https://wty10hv6az.sealosbja.site/medicine-scan

用途:
- 药物识别: 前端拍照后上传图片，由后端调用「腾讯云 智能导诊-大模型问药拍药盒」识别药盒信息
- 后端基于识别结果（批准文号/产品名）查询 MySQL 药品库并返回候选药品列表

请求体:
- userId: string (可选)
- imageBase64: string (必填，图片 base64，不带 data:image 前缀)
- mimeType: string (可选，默认 image/jpeg)

返回体:
- code: string
- msg: string
- result:
  - candidates: Candidate[]
  - thumbBase64: string (可选，可为空；建议由前端本地生成缩略图)

Candidate 字段:
- drugCode: string
- approvalNo: string
- productName: string
- dosageForm: string
- specification: string
- manufacturer: string
- score: number (可选，0~1)

核心说明（重要）:
- 腾讯云图片接口 `GetLLMDiagnosisDrug` 仅支持 `ImageUrl`，不支持 base64
- 所以后端需要把 base64 临时上传到 COS，再用 10 分钟预签名 URL 作为 ImageUrl 调腾讯云
- 调用完成后必须删除 COS 临时对象（避免堆积与泄露）

所需环境变量:
1) 腾讯云签名:
- TENCENTCLOUD_SECRET_ID
- TENCENTCLOUD_SECRET_KEY
- TENCENTCLOUD_REGION (例如 ap-guangzhou)

2) 智能导诊业务参数:
- IG_PARTNER_ID
- IG_PARTNER_SECRET
- IG_HOSPITAL_APP_ID

3) COS（临时 URL 用）:
- COS_BUCKET (例如 your-bucket-1234567890)
- COS_REGION (例如 ap-guangzhou)

参考接口文档:
- GetLLMDiagnosisDrug: https://cloud.tencent.com/document/product/1273/128049

示例代码（Laf 云函数，TypeScript）
```typescript
import cloud from '@lafjs/cloud'
import crypto from 'crypto'
import COS from 'cos-nodejs-sdk-v5'
import { Client } from 'tencentcloud-sdk-nodejs-ig'

const db = cloud.database()

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

function uuid() {
  return crypto.randomUUID ? crypto.randomUUID() : crypto.randomBytes(16).toString('hex')
}

function stripDataUrl(base64: string) {
  // 兼容前端误传 data:image/xxx;base64,....
  const idx = base64.indexOf('base64,')
  return idx >= 0 ? base64.substring(idx + 7) : base64
}

function parseMaybeJson(text: string): any | null {
  const raw = String(text || '').trim()
  if (!raw) return null
  try {
    return JSON.parse(raw)
  } catch (_) {
    // 尝试提取最外层 {...}
    const m = raw.match(/\{[\s\S]*\}/)
    if (!m) return null
    try {
      return JSON.parse(m[0])
    } catch (_) {
      return null
    }
  }
}

export async function main(ctx: FunctionContext) {
  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  const imageBase64 = String((ctx.body as any).imageBase64 || '').trim()
  const mimeType = String((ctx.body as any).mimeType || 'image/jpeg').trim() || 'image/jpeg'
  if (!imageBase64) {
    return fail('imageBase64 不能为空')
  }

  // 1) base64 -> Buffer
  let buf: Buffer
  try {
    buf = Buffer.from(stripDataUrl(imageBase64), 'base64')
  } catch (_) {
    return fail('imageBase64 格式错误')
  }

  // 2) upload to COS (private) -> presigned URL (10 min)
  const cos = new COS({
    SecretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
    SecretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
  })
  const bucket = mustEnv('COS_BUCKET')
  const region = mustEnv('COS_REGION')
  const key = `scan_tmp/${uuid()}.${mimeType.includes('png') ? 'png' : 'jpg'}`

  await cos.putObject({
    Bucket: bucket,
    Region: region,
    Key: key,
    Body: buf,
    ContentType: mimeType,
  })

  const imageUrl = cos.getObjectUrl({
    Bucket: bucket,
    Region: region,
    Key: key,
    Sign: true,
    Expires: 600, // 10 minutes
  })

  // 3) call TencentCloud IG
  const ig = new Client({
    credential: {
      secretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
      secretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
    },
    region: mustEnv('TENCENTCLOUD_REGION'),
    profile: { httpProfile: { endpoint: 'ig.tencentcloudapi.com' } },
  })

  const dialogueId = uuid()
  const resp = await ig.GetLLMDiagnosisDrug({
    // 业务参数（必须）
    PartnerId: mustEnv('IG_PARTNER_ID'),
    PartnerSecret: mustEnv('IG_PARTNER_SECRET'),
    HospitalAppId: mustEnv('IG_HOSPITAL_APP_ID'),

    DialogueId: dialogueId,
    ImageUrl: imageUrl,
    ResultType: 0,
    Message:
      '请识别图片中药品信息，只输出 JSON：' +
      '{productName, approvalNo, manufacturer, dosageForm, specification}，不要输出其它文字。',
  })

  // 4) delete tmp object (best-effort)
  cos.deleteObject({ Bucket: bucket, Region: region, Key: key }).catch(() => {})

  const content = String(resp?.Data?.Content || '').trim()
  const parsed = parseMaybeJson(content) || {}
  const approvalNo = String(parsed.approvalNo || '').trim()
  const productName = String(parsed.productName || '').trim()

  // 5) query mysql medicine库（这里示意：按批准文号优先，否则按产品名模糊）
  // TODO: 复用你现有 /medicine-search 的 MySQL 查询逻辑
  // 返回 candidates 结构必须匹配前端

  return success({
    candidates: [],
    thumbBase64: '',
    // debug: { content, approvalNo, productName }, // 如需排查可临时打开，正式环境不要返回
  })
}
```
