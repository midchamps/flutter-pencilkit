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

  // boundingRect 획득 메서드
  static func getDrawingBoundingRect(result: @escaping FlutterResult) {
      guard let canvasView = canvasView else {
          result(FlutterError(code: "no_canvas", message: "CanvasView not initialized", details: nil))
          return
      }

      let rect = canvasView.drawing.boundingRect
      // rect 정보를 Flutter로 전달
      result(["x": rect.origin.x, "y": rect.origin.y, "width": rect.width, "height": rect.height])
  }

  // 해당 영역의 이미지를 PNG로 추출 메서드
  static func getDrawingImage(result: @escaping FlutterResult) {
      guard let canvasView = canvasView else {
          result(FlutterError(code: "no_canvas", message: "CanvasView not initialized", details: nil))
          return
      }

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
    switch call.method {
      case "checkAvailable":
          // iOS 13 이상에서 PencilKit 사용 가능
          result(ProcessInfo().operatingSystemVersion.majorVersion >= 13)
      case "getDrawingBoundingRect":
          SwiftPencilKitPlugin.getDrawingBoundingRect(result: result)
      case "getDrawingImage":
          SwiftPencilKitPlugin.getDrawingImage(result: result)
      default:
          result(FlutterMethodNotImplemented)
    }
  }
}
