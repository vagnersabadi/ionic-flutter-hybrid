package io.ionic.starter.plugins

import android.app.Activity
import androidx.activity.result.ActivityResult
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.ActivityCallback
import com.getcapacitor.annotation.CapacitorPlugin
import io.flutter.embedding.android.FlutterActivity

/**
 * FlutterRouterPlugin — Android (Kotlin)
 *
 * Plugin Capacitor que abre o Flutter Engine como FlutterActivity,
 * navega para a rota especificada e retorna ao Ionic quando o usuario
 * fecha a tela Flutter.
 *
 * Como registrar no MainActivity.kt:
 *   override fun onCreate(savedInstanceState: Bundle?) {
 *     registerPlugin(FlutterRouterPlugin::class.java)
 *     super.onCreate(savedInstanceState)
 *   }
 */
@CapacitorPlugin(name = "FlutterRouter")
class FlutterRouterPlugin : Plugin() {

    companion object {
        const val CHANNEL_NAME = "com.example.hybrid/flutter_router"
        const val EXTRA_ROUTE = "flutter_route"
        const val EXTRA_PARAMS = "flutter_params"
    }

    /**
     * Navega para uma tela Flutter.
     * Parametros JS: { route: string, params?: object }
     */
    @PluginMethod
    fun navigateTo(call: PluginCall) {
        val route = call.getString("route") ?: run {
            call.reject("O parametro 'route' e obrigatorio")
            return
        }
        val params = call.getObject("params")?.toString() ?: "{}"

        // Cria a FlutterActivity com a rota inicial desejada
        val flutterIntent = FlutterActivity
            .NewEngineIntentBuilder(HybridFlutterActivity::class.java)
            .initialRoute(route)
            .build(activity)
            .apply {
                putExtra(EXTRA_ROUTE, route)
                putExtra(EXTRA_PARAMS, params)
            }

        // Salva o call — sera resolvido no callback handleFlutterResult
        bridge.saveCall(call)
        startActivityForResult(call, flutterIntent, "handleFlutterResult")
    }

    /**
     * Callback chamado quando FlutterActivity termina.
     * Retorna { completed: boolean, data?: object } ao Ionic.
     */
    @ActivityCallback
    private fun handleFlutterResult(call: PluginCall, result: ActivityResult) {
        val ret = JSObject()
        if (result.resultCode == Activity.RESULT_OK) {
            ret.put("completed", true)
            result.data?.extras?.let { extras ->
                val data = JSObject()
                for (key in extras.keySet()) {
                    data.put(key, extras.get(key).toString())
                }
                ret.put("data", data)
            }
        } else {
            ret.put("completed", false)
        }
        call.resolve(ret)
    }

    @PluginMethod
    fun goBack(call: PluginCall) {
        activity.runOnUiThread {
            activity.finish()
        }
        call.resolve()
    }
}
