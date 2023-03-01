package com.cttic.navi.flutter_cttic_navi

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterCtticNaviPlugin */
class FlutterCtticNaviPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var binding : FlutterPlugin.FlutterPluginBinding? = null
  private  var activity : Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_cttic_navi")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "startAmapNavigation" || call.method == "startDockNavigation") {
      val enity = call.argument<String>("enity")
      val simulationEnabled = call.argument<Boolean>("simulationEnabled")
      enity?.let { Log.i("FlutterCtticNaviPlugin", it) }
      val packName = "cn.ctticsh.msd"
      val packManager = binding?.applicationContext?.packageManager
      val intent = packManager?.getLaunchIntentForPackage(packName)
      intent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      val bundle = Bundle()
      val encryptedText = enity?.let { encryptByRsa("public.pem", it) }
      bundle.putString("msd", encryptedText)
      if (simulationEnabled != null) {
        bundle.putBoolean("simulationEnabled", simulationEnabled)
      } else {
        bundle.putBoolean("simulationEnabled", false)
      }
      intent?.putExtras(bundle)
      if (intent != null && activity != null) {
        activity!!.startActivity(intent)
        result.success(true)
      } else {
        result.success(false)
      }
    } else if (call.method == "isMsdAppInstalled") {
      val installed = Utils.checkMsdInstalled(binding?.applicationContext, "cn.ctticsh.msd")
      result.success(installed)
    } else {
      result.notImplemented()
    }
  }

  fun encryptByRsa(pem: String, content: String): String {
    val rsa = binding?.applicationContext?.assets?.open(pem)?.bufferedReader().use {
      it?.readText() ?: ""
    }
    val contentBytes = Utils.encryptByPublicKeyForSpilt(content.toByteArray(), rsa.toByteArray())
    return Base64.encodeToString(contentBytes, Base64.DEFAULT)
  }

  fun decryptByRsa(pem: String, content: String): String {
    val rsa = binding?.applicationContext?.assets?.open(pem)?.bufferedReader().use {
      it?.readText() ?: ""
    }
    val contentBytes = Utils.decryptByPrivateKeyForSpilt(Base64.decode(content, Base64.DEFAULT), rsa.toByteArray())
    return String(contentBytes)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    this.binding = null
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}