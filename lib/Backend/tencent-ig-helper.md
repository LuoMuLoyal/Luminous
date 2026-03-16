建议新增共享文件: `ig_client.ts`

用途:
- 统一封装腾讯云智能导诊 `GetLLMDiagnosisDrug` / `GetLLMDiagnosisDrugChat`
- 统一封装 COS 临时图片上传、预签名 URL、删除临时对象
- 避免 `/medicine-scan`、`/medicine-ai-detail`、`/medicine-ai-safety` 三个云函数重复写鉴权/环境变量代码

依赖:
- `tencentcloud-sdk-nodejs-ig`
- `cos-nodejs-sdk-v5`

环境变量:
- `TENCENTCLOUD_SECRET_ID`
- `TENCENTCLOUD_SECRET_KEY`
- `TENCENTCLOUD_REGION`
- `IG_PARTNER_ID`
- `IG_PARTNER_SECRET`
- `IG_HOSPITAL_APP_ID`
- `COS_BUCKET`
- `COS_REGION`

示例代码:
```typescript
import crypto from 'crypto'
import COS from 'cos-nodejs-sdk-v5'
import { Client } from 'tencentcloud-sdk-nodejs-ig'

export function mustEnv(name: string) {
  const v = String(process.env[name] || '').trim()
  if (!v) throw new Error(`缺少环境变量: ${name}`)
  return v
}

export function createIgClient() {
  return new Client({
    credential: {
      secretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
      secretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
    },
    region: mustEnv('TENCENTCLOUD_REGION'),
    profile: { httpProfile: { endpoint: 'ig.tencentcloudapi.com' } },
  })
}

export function createCosClient() {
  return new COS({
    SecretId: mustEnv('TENCENTCLOUD_SECRET_ID'),
    SecretKey: mustEnv('TENCENTCLOUD_SECRET_KEY'),
  })
}

export function buildBusinessParams() {
  return {
    PartnerId: mustEnv('IG_PARTNER_ID'),
    PartnerSecret: mustEnv('IG_PARTNER_SECRET'),
    HospitalAppId: mustEnv('IG_HOSPITAL_APP_ID'),
  }
}

export function newDialogueId() {
  return crypto.randomUUID ? crypto.randomUUID() : crypto.randomBytes(16).toString('hex')
}

export async function uploadTmpImageAndGetUrl(
  cos: COS,
  bytes: Buffer,
  mimeType = 'image/jpeg',
) {
  const bucket = mustEnv('COS_BUCKET')
  const region = mustEnv('COS_REGION')
  const ext = mimeType.includes('png') ? 'png' : 'jpg'
  const key = `scan_tmp/${newDialogueId()}.${ext}`

  await cos.putObject({
    Bucket: bucket,
    Region: region,
    Key: key,
    Body: bytes,
    ContentType: mimeType,
  })

  const imageUrl = cos.getObjectUrl({
    Bucket: bucket,
    Region: region,
    Key: key,
    Sign: true,
    Expires: 600,
  })

  return { key, bucket, region, imageUrl }
}

export async function deleteTmpImage(cos: COS, bucket: string, region: string, key: string) {
  try {
    await cos.deleteObject({ Bucket: bucket, Region: region, Key: key })
  } catch (_) {}
}

export async function callDrugImageModel(imageUrl: string, message: string) {
  const ig = createIgClient()
  return ig.GetLLMDiagnosisDrug({
    ...buildBusinessParams(),
    DialogueId: newDialogueId(),
    ImageUrl: imageUrl,
    Message: message,
    ResultType: 0,
  })
}

export async function callDrugChatModel(message: string) {
  const ig = createIgClient()
  return ig.GetLLMDiagnosisDrugChat({
    ...buildBusinessParams(),
    DialogueId: newDialogueId(),
    Message: message,
    ResultType: 0,
  })
}
```

建议:
- `/medicine-scan` 只负责：解码 base64 -> 上传 COS -> `callDrugImageModel` -> 提取关键词 -> 查 MySQL -> 删除临时图片
- `/medicine-ai-detail` 与 `/medicine-ai-safety` 只负责：组装 prompt -> `callDrugChatModel`
- 若后续要加重试/日志/耗时统计，也统一放在这个 helper 里

