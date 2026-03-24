访问地址: https://wty10hv6az.sealosbja.site

函数路径:
- POST /scan-record-create
- POST /scan-record-list

公网访问路径:
- https://wty10hv6az.sealosbja.site/scan-record-create
- https://wty10hv6az.sealosbja.site/scan-record-list

用途:
- 相册记录同步: 前端拍照识别后，把“缩略图 + 识别结果”同步到后端，当前客户端不再回拉历史列表

请求体: POST /scan-record-create
- userId: string (必填)
- thumbBase64: string (必填)
- drugCode: string (可选)
- approvalNo: string (可选)
- productName: string (可选)
- takenAt: number (可选，毫秒时间戳)

返回体: POST /scan-record-create
- code: string
- msg: string
- result: { id: string }

请求体: POST /scan-record-list
- userId: string (必填)
- page: number (可选，默认 1)
- pageSize: number (可选，默认 20)

返回体: POST /scan-record-list
- code: string
- msg: string
- result:
  - items: ScanRecordItem[]
  - total: number
  - page: number
  - pageSize: number

ScanRecordItem 字段:
- id: string
- thumbBase64: string
- drugCode: string
- approvalNo: string
- productName: string
- takenAt: number

示例代码（Laf 云函数）
```typescript
import cloud from '@lafjs/cloud'

const db = cloud.database()
const COL = 'scan_records'

function success(result: any, msg = '') {
  return { code: '1', msg, result }
}

function fail(msg: string, code = '0') {
  return { code, msg, result: null }
}

export async function main(ctx: FunctionContext) {
  // 按云函数文件名区分：scan-record-create / scan-record-list
  // 你也可以拆成两个文件分别部署。
  const fn = String(ctx.__function_name || '').trim()

  if (!ctx.body || typeof ctx.body !== 'object') {
    return fail('请求参数格式错误')
  }

  if (fn.includes('scan-record-create')) {
    const userId = String((ctx.body as any).userId || '').trim()
    const thumbBase64 = String((ctx.body as any).thumbBase64 || '').trim()
    if (!userId) return fail('userId 不能为空')
    if (!thumbBase64) return fail('thumbBase64 不能为空')

    const takenAt = Number((ctx.body as any).takenAt || Date.now())
    const drugCode = String((ctx.body as any).drugCode || '').trim()
    const approvalNo = String((ctx.body as any).approvalNo || '').trim()
    const productName = String((ctx.body as any).productName || '').trim()

    const { id } = await db.collection(COL).add({
      userId,
      thumbBase64,
      drugCode,
      approvalNo,
      productName,
      takenAt,
      createdAt: Date.now(),
    })
    return success({ id })
  }

  if (fn.includes('scan-record-list')) {
    const userId = String((ctx.body as any).userId || '').trim()
    if (!userId) return fail('userId 不能为空')

    const page = Math.max(1, Number((ctx.body as any).page || 1))
    const pageSize = Math.min(50, Math.max(1, Number((ctx.body as any).pageSize || 20)))
    const skip = (page - 1) * pageSize

    const query = db.collection(COL).where({ userId })
    const total = (await query.count()).total
    const { data } = await query
      .orderBy('takenAt', 'desc')
      .skip(skip)
      .limit(pageSize)
      .get()

    const items = (data || []).map((r: any) => ({
      id: r._id,
      thumbBase64: r.thumbBase64 || '',
      drugCode: r.drugCode || '',
      approvalNo: r.approvalNo || '',
      productName: r.productName || '',
      takenAt: Number(r.takenAt || 0),
    }))
    return success({ items, total, page, pageSize })
  }

  return fail('未知函数')
}
```
