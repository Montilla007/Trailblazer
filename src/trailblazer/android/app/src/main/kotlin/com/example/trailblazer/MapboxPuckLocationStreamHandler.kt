package com.example.trailblazer

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import com.mapbox.maps.MapView
import com.mapbox.maps.plugin.locationcomponent.OnIndicatorPositionChangedListener
import com.mapbox.maps.plugin.locationcomponent.location
import io.flutter.plugin.common.EventChannel

internal class MapboxPuckLocationStreamHandler(
    private val activity: Activity,
) : EventChannel.StreamHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var mapView: MapView? = null
    private var locationListener: OnIndicatorPositionChangedListener? = null
    private var attachTask: Runnable? = null
    private var attachAttempts = 0

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        stopListening()
        eventSink = events
        attachAttempts = 0

        val task = object : Runnable {
            override fun run() {
                val foundMapView = findMapView(activity.window.decorView)
                if (foundMapView != null) {
                    attach(foundMapView)
                    return
                }

                attachAttempts++
                if (attachAttempts >= MAX_ATTACH_ATTEMPTS) {
                    eventSink?.error(
                        "map_view_not_found",
                        "Could not attach to the Mapbox location puck.",
                        null,
                    )
                    eventSink = null
                    attachTask = null
                    return
                }

                mainHandler.postDelayed(this, ATTACH_RETRY_INTERVAL_MS)
            }
        }
        attachTask = task
        mainHandler.post(task)
    }

    override fun onCancel(arguments: Any?) {
        stopListening()
    }

    fun dispose() {
        stopListening()
    }

    private fun attach(view: MapView) {
        val listener = OnIndicatorPositionChangedListener { point ->
            eventSink?.success(
                mapOf(
                    "latitude" to point.latitude(),
                    "longitude" to point.longitude(),
                ),
            )
        }

        mapView = view
        locationListener = listener
        view.location.addOnIndicatorPositionChangedListener(listener)
        attachTask = null
    }

    private fun stopListening() {
        attachTask?.let(mainHandler::removeCallbacks)
        attachTask = null
        locationListener?.let { listener ->
            mapView?.location?.removeOnIndicatorPositionChangedListener(listener)
        }
        locationListener = null
        mapView = null
        eventSink = null
    }

    private fun findMapView(view: View): MapView? {
        if (view is MapView) return view
        if (view !is ViewGroup) return null

        for (index in 0 until view.childCount) {
            findMapView(view.getChildAt(index))?.let { return it }
        }

        return null
    }

    private companion object {
        const val ATTACH_RETRY_INTERVAL_MS = 100L
        const val MAX_ATTACH_ATTEMPTS = 50
    }
}
