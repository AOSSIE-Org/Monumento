package com.jddeep.monumento

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.Serializable

class MainActivity : FlutterActivity() {

    private val SPLASH_TIME_OUT: Long = 3000
    private val CHANNEL_ONE = "monument_detector"
    private val CHANNEL_TWO = "ar_fragment"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor
            .executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        Log.e("Main Activity", "Configure Engine called")
        MethodChannel(flutterEngine.dartExecutor, CHANNEL_ONE).setMethodCallHandler { call, _ ->
            Log.e("Main Activity", "Method Channel ONE called")
            if (call.method == "navMonumentDetector") {
                val monumentsListMap = call.argument<List<Map<String, String>>>("monumentsList")
                Log.e(
                    "MainActivityList: ",
                    monumentsListMap?.toString() ?: "null"
                )
                navMonumentDetector(monumentsListMap)
            }
        }
        MethodChannel(flutterEngine.dartExecutor, CHANNEL_TWO).setMethodCallHandler { call, _ ->
            Log.e("Main Activity", "Method Channel TWO called")
            if (call.method == "navArFragment") {
                val monument = call.argument<List<Map<String, String>>>("monumentListMap")
                    .let {
                        it?.get(0)?.get("name")?.trim()
                    }
                Log.e(
                    "MainActivityMonument: ",
                    monument ?: "null"
                )
                val monumentListMap = call.argument<List<Map<String, String>>>("monumentListMap")
                Log.e(
                    "MainActivityList: ",
                    monumentListMap?.toString() ?: "null"
                )
                navArFragment(monument, monumentListMap)
            }
        }
    }

    private fun navMonumentDetector(monumentsListMap: List<Map<String, String>>?) {
        val intent = Intent(this, MonumentDetector::class.java)
        intent.putExtra("monumentsListMap", monumentsListMap as Serializable)
        startActivity(intent)
    }

    private fun navArFragment(monument: String?, monumentListMap: List<Map<String, String>>?) {
        val intent = Intent(this, SceneformFragment::class.java)
        intent.putExtra("monument", monument)
        intent.putExtra("monumentListMap", monumentListMap as Serializable)
        startActivity(intent)
    }
}
