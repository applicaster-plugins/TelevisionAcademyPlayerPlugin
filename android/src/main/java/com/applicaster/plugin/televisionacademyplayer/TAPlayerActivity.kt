package com.applicaster.plugin.televisionacademyplayer

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_CONTENT_GROUP
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_CURRENT_PROGRESS
import com.applicaster.plugin_manager.playersmanager.Playable
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.listener.OnReadyListener
import com.bitmovin.player.cast.BitmovinCastManager
import com.bitmovin.player.config.media.SourceConfiguration
import kotlinx.android.synthetic.main.activity_player.*

class TAPlayerActivity : AppCompatActivity() {

    private var bitmovinPlayer: BitmovinPlayer? = null
    private var playable: Playable? = null
    private var currentProgress: Double = 0.0
    private var contentGroup: String = ""
    private val TAG = "TAPlayerActivity"
    private var bitmovinAnalyticInteractor: BitmovinAnalyticInteractor
//    private val testUrl = "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd"

    init {
        //Important to initialise BitmovinCastManager after applicaster to make sync work correctly.
        if (!BitmovinCastManager.isInitialized()) {
            if (ConfigurationRepository.chromeCastAppId.isNullOrEmpty()) {
                BitmovinCastManager.initialize()
            } else {
                BitmovinCastManager.initialize(ConfigurationRepository.chromeCastAppId, null)
            }
        }
        bitmovinAnalyticInteractor = BitmovinAnalyticInteractor()
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window.setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        BitmovinCastManager.getInstance().updateContext(this)
        intent.extras?.apply {
            playable = getSerializable(PlayerContract.KEY_PLAYABLE) as? Playable
            currentProgress = getDouble(KEY_CURRENT_PROGRESS, 0.0)
            contentGroup = getString(KEY_CONTENT_GROUP, "")
        }
        if (savedInstanceState != null) {
            currentProgress = savedInstanceState.getDouble(KEY_CURRENT_PROGRESS, 0.0)
        }
        setContentView(R.layout.activity_player)
        bitmovinPlayer = bitmovinPlayerView.player
        bitmovinAnalyticInteractor.initializeAnalyticsCollector(applicationContext, playable)
        initializePlayer()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            this.window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
        }
    }

    override fun onStart() {
        super.onStart()
        bitmovinPlayerView.onStart()
    }

    override fun onResume() {
        super.onResume()
        bitmovinPlayerView.onResume()
    }

    override fun onPause() {
        bitmovinPlayerView.onPause()
        AnalyticsAgentUtil.logPlayerEnterBackground()
        super.onPause()
    }

    override fun onStop() {
        bitmovinPlayerView.onStop()
        super.onStop()
    }

    override fun onDestroy() {
        bitmovinPlayerView.onDestroy()
        when {
            playable?.isLive == true -> AnalyticsAgentUtil.PLAY_CHANNEL
            else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
        }.let { AnalyticsAgentUtil.endTimedEvent(it) }
        EventListenerInteractor.removeListeners(bitmovinPlayer)
        bitmovinAnalyticInteractor.detachPlayer()
        super.onDestroy()
    }

    private fun initializePlayer() {
        getContentVideoUrl()?.apply {
            // TODO:: uncomment it and use vrSourceItem as a source to turn on VR
//            val vrSourceItem = SourceItem(this)
//            // Get the current VRConfiguration of the SourceItem
//            val vrConfiguration = vrSourceItem.vrConfiguration
//            // Set the VrContentType on the VRConfiguration
//            vrConfiguration.vrContentType = VRContentType.SINGLE
//            // Set the start position to 180 degrees
//            vrConfiguration.startPosition = 180.0

            val sourceConfiguration = SourceConfiguration()
            sourceConfiguration.addSourceItem(this)
            Log.d(TAG, "SET currentProgress :: $currentProgress sec")
            sourceConfiguration.startOffset = currentProgress
            bitmovinPlayer?.load(sourceConfiguration)
            EventListenerInteractor.addListeners(bitmovinPlayer, playable?.playableId
                    ?: "", contentGroup)

            bitmovinPlayer?.addEventListener(OnReadyListener {
                bitmovinAnalyticInteractor.attachPlayer(bitmovinPlayer)
                bitmovinPlayer?.play()
            })
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putDouble(KEY_CURRENT_PROGRESS, bitmovinPlayer?.currentTime
                ?: 0.0)
        outState.putSerializable(PlayerContract.KEY_PLAYABLE, playable)
    }


    private fun getContentVideoUrl() =
            if (ConfigurationRepository.testVideoUrl.isEmpty()) playable?.contentVideoURL else ConfigurationRepository.testVideoUrl
}
