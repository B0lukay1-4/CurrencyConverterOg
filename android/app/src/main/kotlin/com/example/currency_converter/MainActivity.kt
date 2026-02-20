package com.example.currency_converter
import io.flutter.embedding.android.FlutterActivity
import com.facebook.FacebookSdk
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        FacebookSdk.setClientToken("78189f858d1d4b262b459eff6a32c914") // Add this line with your token
        FacebookSdk.sdkInitialize(applicationContext)
        super.onCreate(savedInstanceState)
    }
}