package dk.youtec.drchannels

import android.os.Bundle
import dk.youtec.appupdater.updateApp

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    if(savedInstanceState == null) {
      updateApp(this,
              BuildConfig.VERSION_CODE,
              "https://www.dropbox.com/s/9nn23pjnocityi8/drchannels-flutter.json?dl=1",
              "https://www.dropbox.com/s/k0beuis03cf4zao/drchannels-flutter.apk?dl=1",
              "")
    }
  }
}
