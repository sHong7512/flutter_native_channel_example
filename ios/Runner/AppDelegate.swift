import UIKit
import Flutter

// TODO: swift 코드는 공부 필요.
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        makeRandomChannel()
        
        makeCountChannel()

        makeOverlayChannel()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func makeRandomChannel(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "example.com/Random",binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler({ [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "getRandomNumber":
                let randNum = Int.random(in: 1..<100)
                result(randNum)
            case "getRandomString":
                let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                let randString = String((0..<4).map { _ in letters.randomElement()! })
                result(randString)
            case "showNativeOverlay":
                // IOS 네이티브 오버레이 예제
                OverlayManager.shared.showOverlay()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }

    // IOS 네이티브 오버레이 예제
    func makeOverlayChannel(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "example.com/Overlay",binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler({ [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
               case "showNativeOverlay":
                OverlayManager.shared.showOverlay()
                result(nil)
               default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    func makeCountChannel(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let eventChannel = FlutterEventChannel(name: "example.com/Count",binaryMessenger: controller.binaryMessenger)
        
        eventChannel.setStreamHandler(RandomNumberStreamHandler())
    }
}

class RandomNumberStreamHandler: NSObject, FlutterStreamHandler{
    var sink: FlutterEventSink?
    var timer: Timer?
    var cnt: Int = 0
    
    @objc func sendNewRandomNumber() {
        guard let sink = sink else { return }
        cnt += 1
        sink(cnt)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendNewRandomNumber), userInfo: nil, repeats: true)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        timer?.invalidate()
        cnt = 0
        return nil
    }
}


class OverlayViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = UIScreen.main.bounds
        view.backgroundColor = .blue

        let titleLabel = UILabel()
        titleLabel.text = "오버레이 화면"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 50)
        view.addSubview(titleLabel)

        let closeButton = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 50))
        closeButton.setTitle("닫기", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .red
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    @objc private func closeOverlay() {
        OverlayManager.shared.hideOverlay()
    }
}

class OverlayManager {
    static let shared = OverlayManager()

    private var overlayWindow: UIWindow?

    func showOverlay() {
        guard overlayWindow == nil else { return }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert + 1  // 항상 앱 위에 표시
        window.backgroundColor = .yellow  // 일반 화면처럼 설정

        let overlayVC = OverlayViewController()
        overlayVC.modalPresentationStyle = .fullScreen // 전체 화면 적용

        window.rootViewController = overlayVC
        window.makeKeyAndVisible()

        overlayWindow = window
    }

    func hideOverlay() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
}

