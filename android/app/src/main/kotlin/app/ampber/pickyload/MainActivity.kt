package app.ampber.pickyload

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Debug: Verify Google Maps API Key is loaded from manifest
        try {
            val appInfo = packageManager.getApplicationInfo(
                packageName,
                PackageManager.GET_META_DATA
            )
            val apiKey = appInfo.metaData?.getString("com.google.android.geo.API_KEY")

            if (apiKey != null && apiKey.isNotEmpty()) {
                val maskedKey = apiKey.take(4) + "..." + apiKey.takeLast(4)
                Log.d("MainActivity", "✓ Google Maps API Key found in manifest: $maskedKey (length: ${apiKey.length})")
            } else {
                Log.e("MainActivity", "✗ ERROR: Google Maps API Key NOT found in manifest!")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error checking API key: ${e.message}")
        }
    }
}
