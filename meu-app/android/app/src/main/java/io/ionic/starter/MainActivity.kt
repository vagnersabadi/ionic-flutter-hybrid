package io.ionic.starter

import android.os.Bundle
import com.getcapacitor.BridgeActivity
import io.ionic.starter.plugins.FlutterRouterPlugin

/**
 * MainActivity — Android
 *
 * Registra o FlutterRouterPlugin no Capacitor Bridge.
 * Coloque este arquivo em: android/app/src/main/java/com/example/ionicflutterhybrid/
 */
class MainActivity : BridgeActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // IMPORTANTE: registrar o plugin ANTES de super.onCreate()
        registerPlugin(FlutterRouterPlugin::class.java)
        super.onCreate(savedInstanceState)
    }
}
