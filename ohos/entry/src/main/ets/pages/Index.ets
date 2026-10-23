import { hilog } from '@kit.PerformanceAnalysisKit';
import { webview } from '@kit.ArkWeb';

const DOMAIN = 0x0000;
const TAG = 'LuminousWeb';

@Entry
@Component
struct Index {
  // 本地 rawfile 入口。是否支持子目录与相对子资源解析，
  // 是 Phase 0 的 U1/U2/U6 三个待验证项的核心，需真机确认。
  private controller: webview.WebviewController = new webview.WebviewController();
  @State private renderError: string = '';

  build() {
    Stack() {
      Web({ src: $rawfile('web/index.html'), controller: this.controller })
        .domStorageAccess(true)   // U3：localStorage 持久化，会话与 drift 都依赖它
        .fileAccess(true)
        .javaScriptAccess(true)
        .mixedMode(MixedMode.All)
        .onControllerAttached(() => {
          hilog.info(DOMAIN, TAG, '%{public}s', 'controller attached');
        })
        .onPageBegin((event) => {
          hilog.info(DOMAIN, TAG, 'pageBegin %{public}s', event.url);
        })
        .onPageEnd((event) => {
          hilog.info(DOMAIN, TAG, 'pageEnd %{public}s', event.url);
        })
        .onConsole((event) => {
          hilog.info(DOMAIN, TAG, 'console: %{public}s', event.message.getMessage());
          return false;
        })
        // 白屏时把原始错误直接显示出来，避免"什么都没有"无从排查
        .onErrorReceive((event) => {
          const info: WebResourceError | null = event.error;
          if (info) {
            this.renderError = `errorCode=${info.getErrorCode()} ${info.getErrorInfo()}`;
            hilog.error(DOMAIN, TAG, 'errorReceive %{public}s', this.renderError);
          }
          return false;
        })
        .onHttpErrorReceive((event) => {
          const code: number = event.response.getResponseCode();
          this.renderError = `http=${code} ${event.response.getReasonMessage()}`;
          hilog.error(DOMAIN, TAG, 'httpErrorReceive %{public}s', this.renderError);
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
