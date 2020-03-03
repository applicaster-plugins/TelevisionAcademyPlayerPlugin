package com.tva.quickbrickplayerplugin

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.KeyEvent.*
import android.widget.FrameLayout
import com.applicaster.plugin_manager.login.LoginManager
import com.applicaster.util.OSUtil
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.listener.*
import com.bitmovin.player.config.PlaybackConfiguration
import com.bitmovin.player.config.PlayerConfiguration
import com.bitmovin.player.config.StyleConfiguration
import com.bitmovin.player.config.media.SourceConfiguration
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.tva.quickbrickplayerplugin.api.ApiFactory
import com.tva.quickbrickplayerplugin.api.PlayerEvent
import kotlinx.android.synthetic.main.player_view.view.*
import timber.log.Timber
import java.util.concurrent.TimeUnit

class TVAQuickBrickPlayerView(context: Context, attrs: AttributeSet?) : FrameLayout(context, attrs) {


    private var lastTrackTime = 0L
    private var eventListeners = mutableListOf<EventListener<*>>()
    private var elapsedTimeSeconds: Long? = null
    private var contentGroup: String? = null
    private var videoSrc: String? = null
    private var sourceId: String? = null
    //Temporary hardcoded
    private var testVideoSrc: String? = null
    private lateinit var baseSkylarkUrl: String

    private val TAG = TVAQuickBrickPlayerView::class.java.simpleName
    private val SEEKING_OFFSET = 10
    private val TRACK_TIME_INTERVAL = TimeUnit.SECONDS.toMillis(5)
    private var bitmovinPlayer: BitmovinPlayer? = null

    private val apiFactory by lazy {
        ApiFactory(baseSkylarkUrl, LoginManager.getLoginPlugin()?.token ?: "")
    }

    companion object {
        private const val ELAPSED_TIME = "playhead_position"
        private const val CONTENT_GROUP = "content_group"
        private const val VIDEO_QUALITY_TYPE = "video_quality"
        private const val AUDIO_TRACK_TYPE = "audio_quality"
        private const val LANGUAGE_SUBTITLE_TYPE = "language_subtitle"
    }

    init {
        OSUtil.getLayoutInflater(context).inflate(R.layout.player_view, this)
        bitmovinPlayer = bitmovinPlayerView.player
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        bitmovinPlayer?.setup(createPlayerConfiguration())

        bitmovinPlayerView.onResume()
        addEventListener(OnErrorListener { errorEvent ->
            Log.e(TAG, "An Error occurred (${errorEvent.code}): ${errorEvent.message}")
        })
        addEventListener(OnTimeChangedListener {
            trackTime(false)
        })
        addEventListener(OnPlayListener {
            trackTime(false)
        })
        addEventListener(OnPausedListener {
            trackTime(false)
        })
        addEventListener(OnPlaybackFinishedListener {
            trackTime(true)
        })

        bitmovinPlayer?.play()
        bitmovinPlayerView.onStart()
        elapsedTimeSeconds?.let { bitmovinPlayer?.seek(it.toDouble()) }
    }

    private fun createPlayerConfiguration() = PlayerConfiguration().apply {
        if (videoSrc == null) {
            throw IllegalAccessError("Video source must be specified")
        }
        sourceConfiguration = SourceConfiguration().apply {
            addSourceItem(if (testVideoSrc.isNullOrEmpty()) videoSrc!! else testVideoSrc!!)
        }

        styleConfiguration = StyleConfiguration().apply {
            playerUiJs = "file:///android_asset/bitmovinplayer-ui.js"
        }

        playbackConfiguration = PlaybackConfiguration().apply {
            isAutoplayEnabled = true
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        bitmovinPlayerView.onPause()
        bitmovinPlayerView.onStop()
        bitmovinPlayerView.onDestroy()
        eventListeners.forEach { bitmovinPlayer?.removeEventListener(it) }
    }

    fun onKeyChanged(event: ReadableMap?) {
        when (event?.getInt("keyCode")) {
            KEYCODE_DPAD_CENTER,
            KEYCODE_ENTER,
            KEYCODE_NUMPAD_ENTER,
            KEYCODE_SPACE,
            KEYCODE_MEDIA_PLAY_PAUSE -> togglePlay()
            KEYCODE_MEDIA_PLAY -> this.bitmovinPlayer?.play()
            KEYCODE_MEDIA_PAUSE -> this.bitmovinPlayer?.pause()
            KEYCODE_MEDIA_STOP -> stopPlayback()
            KEYCODE_DPAD_RIGHT, KEYCODE_MEDIA_FAST_FORWARD -> seekForward()
            KEYCODE_DPAD_LEFT, KEYCODE_MEDIA_REWIND -> seekBackward()
            KEYCODE_MENU -> showSettingsEvent()
        }
    }

    fun setPlayableItem(source: ReadableMap) {
        videoSrc = source.getMap("content")?.getString("src")
        sourceId = source.getString("id")

        if (source.hasKey("extensions")) {
            source.getMap("extensions")?.apply {
                if (hasKey(ELAPSED_TIME)) {
                    elapsedTimeSeconds = getString(ELAPSED_TIME)?.toLongOrNull()
                }
                if (hasKey(CONTENT_GROUP)) {
                    contentGroup = getString(CONTENT_GROUP)
                }
            }
        }
    }

    fun setPluginConfiguration(params: ReadableMap) {
        this.baseSkylarkUrl = params.getString("baseSkylarkUrl")
                ?: throw IllegalArgumentException("baseSkylarkUrl should be specified in config")
        if (params.hasKey("testVideoSrc")) {
            this.testVideoSrc = params.getString("testVideoSrc")
        }
    }

    fun onSettingSelected(params: ReadableMap) {
        bitmovinPlayer?.let { player ->
            when (params.getString("type")) {
                AUDIO_TRACK_TYPE -> player.setAudioQuality(params.getString("id"))
                VIDEO_QUALITY_TYPE -> player.setVideoQuality(params.getString("id"))
                LANGUAGE_SUBTITLE_TYPE -> player.setSubtitle(params.getString("id"))
            }
        }
    }

    private fun showSettingsEvent() = bitmovinPlayer?.let { player ->
        val settingsData = Arguments.createArray()
        if (player.availableSubtitles.size > 1) {
            val subtitles = Arguments.createMap()
            subtitles.putString("title", "Subtitles:")
            subtitles.putString("subtitle", player.subtitle?.label ?: "off")
            subtitles.putString("selectedId", player.subtitle.id)
            subtitles.putString("type", LANGUAGE_SUBTITLE_TYPE)
            val availableSubtitles = Arguments.createArray()
            player.availableSubtitles.forEach {
                val subtitle = Arguments.createMap()
                subtitle.putString("title", it.label)
                subtitle.putString("type", LANGUAGE_SUBTITLE_TYPE)
                subtitle.putString("id", it.id)
                availableSubtitles.pushMap(subtitle)
            }
            subtitles.putArray("available", availableSubtitles)
            settingsData.pushMap(subtitles)
        }

        var playerAvailableVideoQualities = player.availableVideoQualities
        if (playerAvailableVideoQualities.size > 1) {
            val selectedVideoQuality = if (player.videoQuality == null) {
                "auto"
            } else {
                player.videoQuality.label
            }

            if (player.videoQuality?.label == "auto" && playerAvailableVideoQualities.none { it.label == "auto" }) {
                playerAvailableVideoQualities = arrayOf(player.videoQuality) + playerAvailableVideoQualities
            }

            val videoQualities = Arguments.createMap()
            videoQualities.putString("title", "Video Quality:")
            videoQualities.putString("subtitle", selectedVideoQuality)
            videoQualities.putString("selectedId", player.videoQuality?.id)
            videoQualities.putString("type", VIDEO_QUALITY_TYPE)
            val availableVideoQualities = Arguments.createArray()
            playerAvailableVideoQualities.forEach {
                val videoQuality = Arguments.createMap()
                videoQuality.putString("title", it.label)
                videoQuality.putString("type", VIDEO_QUALITY_TYPE)
                videoQuality.putString("id", it.id)
                availableVideoQualities.pushMap(videoQuality)
            }
            videoQualities.putArray("available", availableVideoQualities)
            settingsData.pushMap(videoQualities)
        }

        if (player.availableAudio.size > 1) {
            val audioTracks = Arguments.createMap()
            audioTracks.putString("title", "Audio Track:")
            audioTracks.putString("subtitle", player.audio?.label ?: "auto")
            audioTracks.putString("selectedId", player.audio?.id)
            audioTracks.putString("type", AUDIO_TRACK_TYPE)
            val availableAudioTracks = Arguments.createArray()
            player.availableAudio.forEach {
                val audioTrack = Arguments.createMap()
                audioTrack.putString("title", it.label)
                audioTrack.putString("type", AUDIO_TRACK_TYPE)
                audioTrack.putString("id", it.id)
                availableAudioTracks.pushMap(audioTrack)
            }
            audioTracks.putArray("available", availableAudioTracks)
            settingsData.pushMap(audioTracks)
        }

        (context as ReactContext).getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit("onShowSettings", settingsData)
    }

    private fun togglePlay() {
        bitmovinPlayer?.let { player ->
            if (player.isPlaying) {
                player.pause()
            } else {
                player.play()
            }
        }
        trackTime(true)
    }

    private fun stopPlayback() {
        bitmovinPlayer?.apply {
            pause()
            seek(0.0)
            trackTime(true, 0.0)
        }
    }

    private fun seekForward() {
        bitmovinPlayer?.let { player ->
            val newTime = player.currentTime.plus(SEEKING_OFFSET)
            player.seek(newTime)
            trackTime(true, newTime)
        }
    }

    private fun seekBackward() {
        bitmovinPlayer?.let { player ->
            val newTime = player.currentTime.minus(SEEKING_OFFSET)
            player.seek(newTime)
            trackTime(true, newTime)

        }
    }

    private fun trackTime(force: Boolean, newTime: Double? = null) {
        if (!force && System.currentTimeMillis() - lastTrackTime < TRACK_TIME_INTERVAL) {
            return
        }
        lastTrackTime = System.currentTimeMillis()
        bitmovinPlayer?.let { player ->
            apiFactory.watchListApi
                    .putWatchlist(sourceId!!, PlayerEvent(
                            player.duration.toLong(),
                            (newTime ?: player.currentTime).toLong(),
                            contentGroup ?: ""))
                    .subscribe({}, { Timber.e(it) })
        }
    }

    fun addEventListener(listener: EventListener<*>) {
        bitmovinPlayer?.addEventListener(listener)
        eventListeners.add(listener)
    }
}
