import Foundation
import Capacitor
import Flutter
import FlutterPluginRegistrant
import UIKit

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
        let route = call.getString("route", "")
        guard !route.isEmpty else {
            call.unavailable("Parametro route e obrigatorio")
            return
        }

        let params = call.getObject("params", [:])

        DispatchQueue.main.async {
            self.launchFlutter(route: route, params: params, call: call)
        }
    }

    @objc public func goBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if let flutterVC = self.activeFlutterViewController {
                flutterVC.dismiss(animated: true) {
                    self.cleanupSession()
                    call.resolve()
                }
                return
            }

            if let topVC = self.topViewController(), topVC.presentingViewController != nil {
                topVC.dismiss(animated: true) {
                    self.cleanupSession()
                    call.resolve()
                }
                return
            }

            call.resolve()
        }
    }

    private func launchFlutter(route: String, params: [String: Any], call: CAPPluginCall) {
        guard let presenter = topViewController() else {
            call.unavailable("Nao foi possivel localizar uma view controller para abrir o Flutter")
            return
        }

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

        presenter.present(flutterVC, animated: true, completion: {
            channel.invokeMethod("navigateTo", arguments: [
                "route": route,
                "params": params,
            ])
        })
    }

    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }

        var current = root
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }

    private func dismissFlutterAndResolve(returnData: [String: Any]) {
        guard let flutterVC = activeFlutterViewController else {
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

        var data: JSObject = [:]
        for (key, value) in returnData {
            if let typed = value as? String {
                data[key] = typed
            } else if let typed = value as? Bool {
                data[key] = typed
            } else if let typed = value as? NSNumber {
                data[key] = typed
            } else {
                data[key] = String(describing: value)
            }
        }

        payload["data"] = data
        call.resolve(payload)
    }

    private func cleanupSession() {
        activeChannel = nil
        activeFlutterViewController = nil
        activeCall = nil
        activeEngine = nil
    }
}
