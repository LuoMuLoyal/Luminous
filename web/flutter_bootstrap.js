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
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});
