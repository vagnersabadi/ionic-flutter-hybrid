import Foundation
import Capacitor
import Flutter
import FlutterPluginRegistrant

/// FlutterRouterPlugin iOS (Swift)
/// Plugin Capacitor que abre telas Flutter via FlutterViewController modal.
/// MethodChannel: com.example.hybrid/flutter_router
///   - Ionic  -> Flutter: navigateTo({ route, params })
///   - Flutter -> Ionic:  goBack(returnData)
@objc(FlutterRouterPlugin)
public class FlutterRouterPlugin: CAPPlugin {

    // MARK: - Properties
    private static let channelName = "com.example.hybrid/flutter_router"
    private var activeEngine: FlutterEngine?
    private var activeChannel: FlutterMethodChannel?

    // MARK: - CAPPlugin Methods

    /// navigateTo — abre uma tela Flutter.
    /// Params JS: { route: String, params?: Object }
    /// Resolve com: { completed: Bool, data?: Object }
    @objc func navigateTo(_ call: CAPPluginCall) {
        guard let route = call.getString("route") else {
            call.reject("Parametro route e obrigatorio")
            return
        }
        let params = call.getObject("params") as? [String: Any] ?? [:]
        DispatchQueue.main.async {
            self.launchFlutter(route: route, params: params, call: call)
        }
    }

    /// goBack — fecha o FlutterViewController programaticamente.
    /// Normalmente chamado pelo Flutter, mas pode ser forcado pelo Ionic.
    @objc func goBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.bridge?.viewController?.presentedViewController?.dismiss(animated: true) {
                call.resolve()
            }
        }
    }

    // MARK: - Private

    private func launchFlutter(route: String, params: [String: Any], call: CAPPluginCall) {
        let engine = FlutterEngine(name: "ionic_hybrid_engine_\(UUID().uuidString)")
        engine.run(withEntrypoint: nil, initialRoute: route)
        GeneratedPluginRegistrant.register(with: engine)
        activeEngine = engine

        guard let activeEngine = activeEngine else {
            call.reject("Falha ao inicializar o Flutter Engine")
            return
        }

        // 2. Cria o FlutterViewController que hospeda a UI Flutter
        let flutterVC = FlutterViewController(engine: activeEngine, nibName: nil, bundle: nil)
        flutterVC.modalPresentationStyle = .fullScreen

        // 3. Configura o MethodChannel para comunicacao bidirecional
        let channel = FlutterMethodChannel(
            name: FlutterRouterPlugin.channelName,
            binaryMessenger: activeEngine.binaryMessenger
        )
        self.activeChannel = channel

        // 4. Handler: processa chamadas vindas do Flutter
        channel.setMethodCallHandler { [weak self, weak flutterVC] methodCall, result in
            guard let self = self else { return }

            switch methodCall.method {

            case "goBack":
                // Flutter solicita fechar a tela e retornar ao Ionic
                let returnData = methodCall.arguments as? [String: Any]

                DispatchQueue.main.async {
                    guard let viewController = flutterVC ?? self.bridge?.viewController?.presentedViewController else {
                        result(nil)
                        return
                    }

                    viewController.dismiss(animated: true) {
                        var ret = JSObject()
                        ret["completed"] = true
                        if let data = returnData {
                            ret["data"] = data
                        }
                        self.activeChannel = nil
                        self.activeEngine = nil
                        call.resolve(ret)
                    }
                }
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // 5. Apresenta o FlutterViewController e notifica o Flutter da rota
        bridge?.viewController?.present(flutterVC, animated: true) {
            channel.invokeMethod("navigateTo", arguments: [
                "route": route,
                "params": params
            ])
        }
    }
}