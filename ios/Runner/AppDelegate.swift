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
