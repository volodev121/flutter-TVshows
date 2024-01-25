package com.Sammour.Masayat

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        // window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
