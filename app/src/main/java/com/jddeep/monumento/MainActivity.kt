package com.jddeep.monumento

import android.os.Bundle
import android.os.Handler
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class MainActivity : AppCompatActivity() {

    private val SPLASH_TIME_OUT: Long = 3000

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        Handler().postDelayed({
            startActivity(FlutterActivity.createDefaultIntent(this))
            finish()
        }, SPLASH_TIME_OUT)

    }
}
