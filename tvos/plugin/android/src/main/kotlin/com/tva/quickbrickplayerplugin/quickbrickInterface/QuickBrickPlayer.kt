package com.tva.quickbrickplayerplugin.quickbrickInterface

import android.util.Log
import android.view.View
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.tva.quickbrickplayerplugin.VideoPlayerEvents
import com.tva.quickbrickplayerplugin.helper.ReactArgumentsBuilder
import com.tva.quickbrickplayerplugin.helper.ReactPropCallback

interface QuickBrickPlayer {
    companion object : ReactPropCallbacks {
        override val reactCallbackPropNames = VideoPlayerEvents.getListOfEvent()
        override val reactCallbackProps = mutableMapOf<String, ReactPropCallback>()
    }

    fun getCurrentTime(): Unit

    fun setPlayableItem(source: ReadableMap)

    fun setPlayerState(state: String?)

    fun getPlayerView(): View

    fun sendEvent(name: String, arguments: WritableMap?) {
        val playerView = getPlayerView()
        val context = playerView.context as ReactContext

        context.getJSModule(RCTEventEmitter::class.java).receiveEvent(
                playerView.id,
                name,
                arguments
        )
    }

    fun onReadyForDisplay() {
        sendEvent(VideoPlayerEvents.eventReady, null)
    }

    fun onLoadStart() {
        Log.d("QB Player Interface", "on load start")
        sendEvent(VideoPlayerEvents.eventLoadStart, null)
    }

    fun onLoad(duration: Double, currentPosition: Double, videoWidth: Int, videoHeight: Int,
               audioTracks: WritableMap, textTracks: WritableMap, videoTracks: WritableMap
    ) {
        val arguments = ReactArgumentsBuilder()
                .putDouble(VideoPlayerEvents.payloadPropDuration, duration)
                .putDouble(VideoPlayerEvents.payloadPropCurrentPosition, currentPosition)
                .putInt(VideoPlayerEvents.payloadPropVideoWidth, videoWidth)
                .putInt(VideoPlayerEvents.payloadPropVideoHeight, videoHeight)
                .putMap(VideoPlayerEvents.payloadPropAudioTracks, audioTracks)
                .putMap(VideoPlayerEvents.payloadPropTextTracks, textTracks)
                .build()

        sendEvent(VideoPlayerEvents.eventLoad, arguments)

    }


    fun onError(errorMessage: String, exception: Exception) {
        val arguments = ReactArgumentsBuilder()
                .putString("message", errorMessage)
                .putString("exception", exception.message ?: "an error occurred")
                .build()

        sendEvent(VideoPlayerEvents.eventError, arguments)
    }

    fun onTimeUpdate(currentPosition: Long, videoDuration: Long){
        val arguments = ReactArgumentsBuilder()
                .putDouble(VideoPlayerEvents.payloadPropCurrentTime, currentPosition / 1000.0)
                .putDouble(VideoPlayerEvents.payloadPropPlayableDuration, videoDuration / 1000.0)
                .build()

        sendEvent(VideoPlayerEvents.eventProgress, arguments)
    }

    fun onProgressChange(currentPosition: Long, bufferedDuration: Long, seekableDuration: Long) {

        val arguments = ReactArgumentsBuilder()
                .putDouble(VideoPlayerEvents.payloadPropCurrentTime, currentPosition / 1000.0)
                .putDouble(VideoPlayerEvents.payloadPropPlayableDuration, bufferedDuration / 1000.0)
                .putDouble(VideoPlayerEvents.payloadPropSeekableDuration, seekableDuration / 1000.0)
                .build()

        sendEvent(VideoPlayerEvents.eventProgress, arguments)
    }

    fun onSeek(currentPosition: Double?, seekTime: Long) {
        currentPosition?.let {
            val arguments = ReactArgumentsBuilder()
                    .putDouble(VideoPlayerEvents.payloadPropCurrentTime, it.div(1000.0))
                    .putDouble(VideoPlayerEvents.payloadPropSeekTime, seekTime / 1000.0)
                    .build()

            sendEvent(VideoPlayerEvents.eventSeek, arguments)
        }
    }

    fun onPlaybackStalled() {
        sendEvent(VideoPlayerEvents.eventStalled, null)
    }

    fun onBuffer() {
        sendEvent(VideoPlayerEvents.eventBuffer, null)
    }

    fun onEnd() {
        sendEvent(VideoPlayerEvents.eventEnd, null)
    }

    fun onFullscreenPlayerWillPresent() {
        sendEvent(VideoPlayerEvents.eventFullscreenDidPresent, null)

    }

    fun onFullscreenPlayerDidPresent() {
        sendEvent(VideoPlayerEvents.eventFullscreenWillDismiss, null)

    }

    fun onFullscreenPlayerWillDismiss() {
        sendEvent(VideoPlayerEvents.eventFullscreenDidDismiss, null)

    }

    fun onFullscreenPlayerDidDismiss() {
        sendEvent(VideoPlayerEvents.eventFullscreenDidDismiss, null)
    }

    fun onExternalPlaybackChange(isExternalPlaybackActive: Boolean) {
        val arguments = ReactArgumentsBuilder()
                .putBoolean(VideoPlayerEvents.payloadPropIsExternalPlaybackActive, isExternalPlaybackActive)
                .build()

        sendEvent(VideoPlayerEvents.eventExternalPlaybackChange, arguments)
    }

    fun onPlaybackRateChange(rate: Long) {
        val arguments = ReactArgumentsBuilder()
                .putDouble(VideoPlayerEvents.payloadPropPlaybackRate, rate.toDouble())
                .build()

        sendEvent(VideoPlayerEvents.eventPlaybackRateChange, arguments)
    }


    fun audioBecomingNoisy() {
        sendEvent(VideoPlayerEvents.eventAudioBecomingNoisy, null)
    }

    fun onPlay() {

        sendEvent(VideoPlayerEvents.eventVideoStart, null)
    }

    fun onPause() {
        sendEvent(VideoPlayerEvents.eventVideoPause, null)
    }
}