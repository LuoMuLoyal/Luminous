import { hilog } from '@kit.PerformanceAnalysisKit';
import { webview } from '@kit.ArkWeb';

const DOMAIN = 0x0000;
const TAG = 'LuminousWeb';

// 自定义域名：只用于壳内拦截，不对应真实站点（官方推荐做法）。
// 用 resource:// 加载会被跨域策略拦掉 fetch()/import()，
// 导致 canvaskit.wasm、main.dart.js 全部加载失败（2026-10-23 模拟器实测），
// 必须换成 https:// 前缀 + onInterceptRequest 替换为 rawfile。
const APP_ORIGIN = 'https://luminous.local';
const ENTRY_PATH = '/index.html';

// 扩展名 → MIME。wasm 必须是 application/wasm，否则
// WebAssembly.instantiateStreaming 会失败（白屏）。
const MIME_BY_EXT: Record<string, string> = {
  'html': 'text/html',
  'htm': 'text/html',
  'js': 'text/javascript',
  'mjs': 'text/javascript',
  'json': 'application/json',
  'wasm': 'application/wasm',
  'css': 'text/css',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'svg': 'image/svg+xml',
  'ico': 'image/x-icon',
  'woff': 'font/woff',
  'woff2': 'font/woff2',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'map': 'application/json',
  'txt': 'text/plain',
  'atlas': 'text/plain',
  'dill': 'application/octet-stream',
  'bin': 'application/octet-stream',
  'dat': 'application/octet-stream',
};

function mimeFor(path: string): string {
  const dot = path.lastIndexOf('.');
  if (dot < 0) {
    return 'application/octet-stream';
  }
  const ext = path.substring(dot + 1).toLowerCase();
  const mime = MIME_BY_EXT[ext];
  return mime !== undefined ? mime : 'application/octet-stream';
}

/** 文本类型才需要 setResponseEncoding；二进制类型设编码会破坏数据。 */
function isTextMime(mime: string): boolean {
  return mime.startsWith('text/') ||
    mime === 'application/json' ||
    mime === 'image/svg+xml';
}

@Entry
@Component
struct Index {
  private controller: webview.WebviewController = new webview.WebviewController();
  @State private renderError: string = '';
  private intercepted: number = 0;
  private fontHits: number = 0;

  /**
   * 把 https://luminous.local/<path> 映射回 rawfile 内的相对路径。
   * 返回 null 表示不是本站请求。
   *
   * 回退字体也走这条路径：web/flutter_bootstrap.js 把引擎的
   * fontFallbackBaseUrl 设成 https://luminous.local/fonts/，
   * 于是 CJK 字形切片请求会以本站 origin 出现，在这里映射到
   * rawfile 的 fonts/ 目录（切片由 scripts/ohos/fetch_fallback_fonts.py 下载）。
   * 用同源而不是 fonts.gstatic.com，是为了避开跨域 fetch 被 CORS 拦掉。
   */
  private rawfilePathFor(url: string): string | null {
    if (!url.startsWith(APP_ORIGIN + '/')) {
      return null;
    }
    if (url.indexOf('/fonts/') >= 0) {
      this.fontHits++;
    }
    let p = url.substring(APP_ORIGIN.length);
    const q = p.indexOf('?');
    if (q >= 0) {
      p = p.substring(0, q);
    }
    const h = p.indexOf('#');
    if (h >= 0) {
      p = p.substring(0, h);
    }
    if (p === '' || p === '/') {
      p = ENTRY_PATH;
    }
    // 去掉开头的 '/'，得到 rawfile 内的相对路径
    return p.startsWith('/') ? p.substring(1) : p;
  }

  build() {
    Stack() {
      Web({ src: APP_ORIGIN + ENTRY_PATH, controller: this.controller })
        .domStorageAccess(true)   // localStorage 持久化：会话与 drift 都依赖它
        .fileAccess(true)
        .javaScriptAccess(true)
        .mixedMode(MixedMode.All)
        .onControllerAttached(() => {
          hilog.info(DOMAIN, TAG, '%{public}s', 'controller attached');
        })
        // 核心：把自定义 https 域名的请求替换成 rawfile 内容
        .onInterceptRequest((event) => {
          const url: string = event.request.getRequestUrl();
          const rel: string | null = this.rawfilePathFor(url);
          if (rel === null) {
            return null;
          }
          this.intercepted++;
          try {
            const response = new WebResourceResponse();
            const mime: string = mimeFor(rel);
            // 顺序有讲究：先设 MIME，再设数据。
            // setResponseEncoding 只对文本类型设置——对 .wasm 等二进制设 utf-8
            // 会被当文本解码并破坏数据，且可能导致 WebAssembly 拿不到正确的
            // application/wasm（模拟器实测报 "Incorrect response MIME type"）。
            response.setResponseMimeType(mime);
            response.setResponseData($rawfile(rel));
            if (isTextMime(mime)) {
              response.setResponseEncoding('utf-8');
            }
            response.setResponseCode(200);
            response.setReasonMessage('OK');
            response.setResponseIsReady(true);
            return response;
          } catch (e) {
            hilog.error(DOMAIN, TAG, 'intercept failed %{public}s %{public}s',
              rel, JSON.stringify(e));
            const notFound = new WebResourceResponse();
            notFound.setResponseCode(404);
            notFound.setReasonMessage('Not Found');
            notFound.setResponseIsReady(true);
            return notFound;
          }
        })
        .onPageBegin((event) => {
          hilog.info(DOMAIN, TAG, 'pageBegin %{public}s', event.url);
        })
        .onPageEnd((event) => {
          hilog.info(DOMAIN, TAG, 'pageEnd %{public}s intercepted=%{public}d',
            event.url, this.intercepted);
        })
        .onConsole((event) => {
          hilog.info(DOMAIN, TAG, 'console: %{public}s', event.message.getMessage());
          return false;
        })
        .onErrorReceive((event) => {
          const info: WebResourceError | null = event.error;
          if (info) {
            const msg = `errorCode=${info.getErrorCode()} ${info.getErrorInfo()}`;
            hilog.error(DOMAIN, TAG, 'errorReceive %{public}s', msg);
            // 只对主文档显示错误浮层，子资源错误不覆盖页面
            if (event.request.isMainFrame()) {
              this.renderError = msg;
            }
          }
          return false;
        })
        .width('100%')
        .height('100%')

      if (this.renderError.length > 0) {
        Column() {
          Text('Web 加载失败')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text(this.renderError)
            .fontSize(13)
            .fontColor(Color.White)
            .margin({ top: 8 })
          Button('重试')
            .margin({ top: 16 })
            .onClick(() => {
              this.renderError = '';
              this.controller.refresh();
            })
        }
        .padding(24)
        .width('100%')
        .backgroundColor('#CC000000')
      }
    }
    .width('100%')
    .height('100%')
  }
}
