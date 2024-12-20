import Flutter
import UIKit

public class SwiftPencilKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(
      FLPencilKitFactory(messenger: registrar.messenger()),
      withId: "plugins.mjstudio/flutter_pencil_kit"
    )

    let channel = FlutterMethodChannel(
      name: "plugins.mjstudio/flutter_pencil_kit/util",
      binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler {
      (call: FlutterMethodCall, result: @escaping FlutterResult) in
      PencilKitUtil.handleMethodCall(call: call, result: result)
    }
  }

  func getDrawingBoundingRect(result: @escaping FlutterResult) {
    let rect = canvasView.drawing.boundingRect
    // rect 정보를 Flutter로 전달 (예: {x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height})
    result(["x": rect.origin.x, "y": rect.origin.y, "width": rect.width, "height": rect.height])
  }

  func getDrawingImage(result: @escaping FlutterResult) {
      let rect = canvasView.drawing.boundingRect
      let image = canvasView.drawing.image(from: rect, scale: UIScreen.main.scale)
      guard let imageData = image.pngData() else {
          result(FlutterError(code: "image_error", message: "Failed to convert image.", details: nil))
          return
      }
      result(FlutterStandardTypedData(bytes: imageData))
  }
}

private enum PencilKitUtil {
  static func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "checkAvailable" {
      result(ProcessInfo().operatingSystemVersion.majorVersion >= 13)
    }
  }
}
