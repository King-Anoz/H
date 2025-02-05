import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Request photo library permission
    PHPhotoLibrary.requestAuthorization { status in
      // Handle authorization status
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
