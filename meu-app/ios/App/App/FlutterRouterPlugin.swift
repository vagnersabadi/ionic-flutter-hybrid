import Foundation
import Capacitor
import Flutter
import FlutterPluginRegistrant

@objc(FlutterRouterPlugin)
public class FlutterRouterPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "FlutterRouterPlugin"
    public let jsName = "FlutterRouter"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "navigateTo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "goBack", returnType: CAPPluginReturnPromise)
    ]

    private static let channelName = "com.example.hybrid/flutter_router"
    private var activeEngine: FlutterEngine?
    private var activeChannel: FlutterMethodChannel?
    private weak var activeFlutterViewController: UIViewController?
    private weak var activeCall: CAPPluginCall?

    @objc public func navigateTo(_ call: CAPPluginCall) {
        guard let route = call.getString("route") else {
            call.reject("Parametro route e obrigatorio")
            return
        }

        let params = call.getObject("params") as? [String: Any] ?? [:]

        DispatchQueue.main.async {
            self.launchFlutter(route: route, params: params, call: call)
        }
    }

    @objc public func goBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let presented = self.bridge?.viewController?.presentedViewController else {
                call.resolve()
                return
            }

            presented.dismiss(animated: true) {
                self.cleanupSession()
                call.resolve()
            }
        }
    }

    private func launchFlutter(route: String, params: [String: Any], call: CAPPluginCall) {
        let engine = FlutterEngine(name: "ionic_hybrid_engine_\(UUID().uuidString)")
        engine.run(withEntrypoint: nil, initialRoute: route)
        GeneratedPluginRegistrant.register(with: engine)

        self.activeEngine = engine
        self.activeCall = call

        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.modalPresentationStyle = .fullScreen
        self.activeFlutterViewController = flutterVC

        let channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: engine.binaryMessenger
        )

        self.activeChannel = channel

        channel.setMethodCallHandler { [weak self] methodCall, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch methodCall.method {
            case "goBack":
                let returnData = methodCall.arguments as? [String: Any] ?? [:]
                DispatchQueue.main.async {
                    self.dismissFlutterAndResolve(returnData: returnData)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        bridge?.viewController?.present(flutterVC, animated: true) {
            channel.invokeMethod("navigateTo", arguments: [
                "route": route,
                "params": params,
            ])
        }
    }

    private func dismissFlutterAndResolve(returnData: [String: Any]) {
        guard let flutterVC = activeFlutterViewController ?? bridge?.viewController?.presentedViewController else {
            resolveNavigationCall(returnData: returnData)
            cleanupSession()
            return
        }

        flutterVC.dismiss(animated: true) {
            self.resolveNavigationCall(returnData: returnData)
            self.cleanupSession()
        }
    }

    private func resolveNavigationCall(returnData: [String: Any]) {
        guard let call = activeCall else { return }
        var payload: JSObject = ["completed": true]
        payload["data"] = returnData
        call.resolve(payload)
    }

    private func cleanupSession() {
        activeChannel = nil
        activeFlutterViewController = nil
        activeCall = nil
        activeEngine = nil
    }
}
