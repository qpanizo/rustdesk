import UIKit
import Flutter
import AVFoundation
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    do {
      // Mix remote audio with other apps while still respecting silent mode.
      try AVAudioSession.sharedInstance().setCategory(.ambient)
    } catch {
      NSLog("Failed to configure audio mixing: %@", error.localizedDescription)
    }
    dummyMethodToEnforceBundling();
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // With the UIScene life cycle, the FlutterViewController only exists once the scene
  // connects, and FlutterAppDelegate reaches its engine through `window`. A launch URL
  // also arrives with the scene instead of in launchOptions, so forward it to plugins here.
  func sceneWillConnect(window: UIWindow?, launchURL: URL?) {
    self.window = window
    GeneratedPluginRegistrant.register(with: self)
    registerLimaFacPermissions()
    var launchOptions: [UIApplication.LaunchOptionsKey: Any] = [:]
    if let launchURL = launchURL {
      launchOptions[.url] = launchURL
    }
    _ = super.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerLimaFacPermissions() {
    guard let registrar = registrar(forPlugin: "LimaFacPermissions") else { return }
    let channel = FlutterMethodChannel(name: "pe.limafac.remote/permissions",
                                       binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "status":
        let camera: String
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: camera = "authorized"
        case .notDetermined: camera = "notDetermined"
        default: camera = "denied"
        }
        let photos: String
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized: photos = "authorized"
        case .limited: photos = "limited"
        case .notDetermined: photos = "notDetermined"
        default: photos = "denied"
        }
        result(["camera": camera, "photos": photos])
      case "open_settings":
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }
        UIApplication.shared.open(url, options: [:]) { opened in result(opened) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
    
  public func dummyMethodToEnforceBundling() {
      dummy_method_to_enforce_bundling();
    session_get_rgba(nil, 0);
  }
}
