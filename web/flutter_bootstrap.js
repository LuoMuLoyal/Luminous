{{flutter_js}}
{{flutter_build_config}}

// Auto-select renderer based on device:
// - Desktop: force CanvasKit for maximum compatibility and performance.
// - Mobile: leave renderer unset so Flutter auto-selects (prefers skwasm
//   on WasmGC-capable browsers, falls back to canvaskit otherwise).
//   CanvasKit on mobile browsers (especially GitHub Pages) can fail to
//   render the full app body, showing only the navigation bar.
const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
  .test(navigator.userAgent);

_flutter.loader.load({
  config: isMobile ? {} : { renderer: 'canvaskit' },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});
