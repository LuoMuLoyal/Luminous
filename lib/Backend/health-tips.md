# 温馨提示接口文档

## 接口地址
`POST /health-tips`

## 功能说明
随机返回一条健康温馨提示，用于首页顶部色块展示。

> **注意**：前端目前已内置 10 条本地文案，随机展示不依赖此接口。  
> 此接口为可选的服务端扩展版本，供后续运营人员动态管理提示内容使用。

---

## 请求参数（均可选）

| 字段   | 类型   | 说明                        |
|--------|--------|-----------------------------|
| count  | number | 返回条数，默认 1，最大 10   |

---

## 响应格式

```json
{
  "code": "1",
  "msg": "success",
  "result": {
    "tip": "按时服药是控制慢性病的第一步，别让遗忘成为健康的绊脚石。",
    "tips": [
      "按时服药是控制慢性病的第一步，别让遗忘成为健康的绊脚石。"
    ]
  }
}
```

---

## 后端实现参考（Node.js / Express）

```js
// health-tips.js
// 部署说明：将此文件放在后端项目路由目录，注册到 app.post('/health-tips', ...)


const TIPS = [
  '按时服药，控制慢病',
  '注意药食禁忌',
  '服药多喝温水',
  '漏服勿加倍补',
  '药品避光防潮',
  '抗生素服满疗程',
  '服药不适立即就医',
  '定期清理过期药',
  '分清饭前饭后服药',
  '作息规律助药效'
];


/**
 * POST /health-tips
 * body: { count?: number }
 */
function healthTipsHandler(req, res) {
  const count = Math.min(parseInt(req.body?.count ?? 1, 10) || 1, 10);

  // Fisher-Yates shuffle 取前 count 条
  const pool = [...TIPS];
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }
  const selected = pool.slice(0, count);

  return res.json({
    code: '1',
    msg: 'success',
    result: {
      tip: selected[0],
      tips: selected,
    },
  });
}

module.exports = healthTipsHandler;
```

---

## 注册到 Express 主路由示例

```js
const healthTipsHandler = require('./routes/health-tips');
app.post('/health-tips', healthTipsHandler);
```

---

## 错误响应

| 场景         | code | msg            |
|--------------|------|----------------|
| 服务器异常   | `0`  | 服务器内部错误 |
