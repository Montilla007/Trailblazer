package com.example.trailblazer

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var puckLocationChannel: EventChannel? = null
    private var puckLocationStreamHandler: MapboxPuckLocationStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val streamHandler = MapboxPuckLocationStreamHandler(this)
        puckLocationStreamHandler = streamHandler
        puckLocationChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PUCK_LOCATION_CHANNEL,
        ).also { channel ->
            channel.setStreamHandler(streamHandler)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        puckLocationChannel?.setStreamHandler(null)
        puckLocationChannel = null
        puckLocationStreamHandler?.dispose()
        puckLocationStreamHandler = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val PUCK_LOCATION_CHANNEL = "trailblazer/mapbox_puck_location"
    }
}
