package com.example.my_smart_thermometer_plugin

import android.content.Context
import android.hardware.camera2.CameraManager
import android.os.Build
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MySmartThermometerPlugin */
class MySmartThermometerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "my_smart_thermometer_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    // Отримуємо системний сервіс камери
    val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    
    try {
        // Отримуємо ID першої камери (зазвичай це задня камера зі спалахом)
        val cameraId = cameraManager.cameraIdList[0]

        when (call.method) {
            "onLight" -> {
                cameraManager.setTorchMode(cameraId, true)
                result.success(true)
            }
            "offLight" -> {
                cameraManager.setTorchMode(cameraId, false)
                result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    } catch (e: Exception) {
        result.error("FLASHLIGHT_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}