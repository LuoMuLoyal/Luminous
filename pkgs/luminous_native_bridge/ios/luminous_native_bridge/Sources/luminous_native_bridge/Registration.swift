import Flutter
import UIKit

public class LuminousNativeBridgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "luminous_native_bridge", binaryMessenger: registrar.messenger())
    let instance = LuminousNativeBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ping":
      result("pong")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
