package io.ionic.starter.plugins

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class HybridFlutterActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FlutterRouterPlugin.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "goBack" -> {
                    val returnIntent = Intent()
                    val args = call.arguments as? Map<*, *>
                    args?.forEach { (key, value) ->
                        if (key is String && value != null) {
                            returnIntent.putExtra(key, value.toString())
                        }
                    }
                    setResult(Activity.RESULT_OK, returnIntent)
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
