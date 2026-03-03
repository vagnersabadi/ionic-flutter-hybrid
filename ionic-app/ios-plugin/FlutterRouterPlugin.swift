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
    private static var sharedEngine: FlutterEngine?
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

        // 1. Inicializa o FlutterEngine compartilhado (apenas uma vez)
        //    Reutilizar o engine evita o custo de re-inicializacao do Dart VM.
        if FlutterRouterPlugin.sharedEngine == nil {
            let engine = FlutterEngine(name: "ionic_hybrid_engine")
            engine.run(withEntrypoint: nil, initialRoute: route)
            GeneratedPluginRegistrant.register(with: engine)
            FlutterRouterPlugin.sharedEngine = engine
        }

        guard let engine = FlutterRouterPlugin.sharedEngine else {
            call.reject("Falha ao inicializar o Flutter Engine")
            return
        }

        // 2. Cria o FlutterViewController que hospeda a UI Flutter
        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.modalPresentationStyle = .fullScreen

        // 3. Configura o MethodChannel para comunicacao bidirecional
        let channel = FlutterMethodChannel(
            name: FlutterRouterPlugin.channelName,
            binaryMessenger: engine.binaryMessenger
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
                    (flutterVC ?? self.bridge?.viewController?.presentedViewController)
                        .flatMap { /bin/sh as? UIViewController }
                        .map { vc in
                            vc.dismiss(animated: true) {
                                var ret = JSObject()
                                ret["completed"] = true
                                if let data = returnData {
                                    var jsData = JSObject()
                                    data.forEach { key, value in
                                        jsData[key] = value as AnyObject
                                    }
                                    ret["data"] = jsData
                                }
                                call.resolve(ret)
                            }
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