import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 1. Setup Method Channel for Timezone
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let timezoneChannel = FlutterMethodChannel(name: "com.shaijo.verso/timezone",
                                              binaryMessenger: controller.binaryMessenger)
    
    timezoneChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getLocalTimezone" {
        // Return the device's timezone identifier
        result(TimeZone.current.identifier)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    // 2. Register Plugins
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}