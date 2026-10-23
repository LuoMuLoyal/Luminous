{{flutter_js}}
{{flutter_build_config}}

// Use canvaskit on all devices for consistent rendering.
//
// Previous approach auto-selected skwasm on mobile (via --wasm build flag),
// but skwasm has layout bugs on mobile browsers where the FScaffold content
// area gets 0 height, causing the bottom nav bar to appear at the top and
// the page body to remain blank.
//
// canvaskit is more mature and renders correctly on both desktop and mobile.
// The splash screen provides visual feedback while the canvaskit WASM loads.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    // Pin the renderer explicitly: plain builds default to canvaskit anyway,
    // but a future --wasm build would silently switch the default to skwasm
    // (the layout bug above). Explicit keeps mobile rendering correct.
    const appRunner = await engineInitializer.initializeEngine({
      renderer: 'canvaskit',
      // 回退字体本地化：Flutter Web 的 CJK 字形不在构建产物里，引擎在运行时
      // 按需从 https://fonts.gstatic.com/s/ 拉 woff2 切片。鸿蒙壳（以及国内
      // 网络）访问不到，表现为所有文字显示成方块（口口口）。
      //
      // 这里把 base URL 指到壳自身的 origin（与页面同源，因此不受 CORS 限制），
      // 由 ohos/entry/src/main/ets/pages/Index.ets 的 onInterceptRequest
      // 把该路径映射到 rawfile 的 fonts/ 目录；切片由
      // scripts/ohos/fetch_fallback_fonts.py 下载。
      //
      // 必须与 Index.ets 的 FONT_ORIGIN 常量保持一致。
      // 浏览器（GitHub Pages）下这个路径不存在，字体回退失败——与引入该配置
      // 之前的行为一致，不影响 Web 版。
      fontFallbackBaseUrl: 'https://luminous.local/fonts/',
    });
    await appRunner.runApp();
  }
});
