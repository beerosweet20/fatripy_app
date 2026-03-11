package com.example.fatripy_app

import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.googlemaps.GoogleMapsPlugin

class MainActivity : FlutterActivity() {
    private val configChannel = "fatripy/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensure platform-view plugins (Google Maps) are registered on Android.
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        try {
            flutterEngine.plugins.add(GoogleMapsPlugin())
        } catch (e: Exception) {
            Log.e("MainActivity", "GoogleMapsPlugin registration failed", e)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, configChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isMapsApiKeyConfigured" -> result.success(isMapsApiKeyConfigured())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isMapsApiKeyConfigured(): Boolean {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            val key = appInfo.metaData?.getString("com.google.android.geo.API_KEY")?.trim().orEmpty()
            key.isNotEmpty() && key != "YOUR_ANDROID_MAPS_API_KEY"
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed reading Maps API key metadata", e)
            false
        }
    }
}
