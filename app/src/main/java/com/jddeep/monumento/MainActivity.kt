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
    private val CHANNEL = "monument_detector"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        setContentView(R.layout.activity_main)
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor
            .executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

//        Handler().postDelayed({
//            startActivity(createDefaultIntent(this))
//            finish()
//        }, SPLASH_TIME_OUT)


    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        Log.e("Main Activity", "Configure Engine called")
        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, _ ->
            Log.e("Main Activity", "Method Channel called")
            if (call.method == "navMonumentDetector") {
                val monumentsListMap = call.argument<List<Map<String, String>>>("monumentsList")
                Log.e(
                    "MainActivityList: ",
                    monumentsListMap?.toString() ?: "null"
                )
                navMonumentDetector(monumentsListMap)
            }
        }
    }

    private fun navMonumentDetector(monumentsListMap: List<Map<String, String>>?) {
        val intent = Intent(this, MonumentDetector::class.java)
        intent.putExtra("monumentsListMap", monumentsListMap as Serializable)
        startActivity(intent)
    }
}
