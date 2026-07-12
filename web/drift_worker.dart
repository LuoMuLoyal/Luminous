// Drift web worker entry point.
// Compiled to drift_worker.js via:
//   dart compile js web/drift_worker.dart -o web/drift_worker.js -O4
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
