package com.applicaster.plugin.televisionacademyplayer

import android.content.res.TypedArray
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.model.APURLPlayable
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.COMPETITION_ID
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_CONTENT_GROUP
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_CURRENT_PROGRESS
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_NEXT_PLAYLIST_ITEM
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_PLAYABLE
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_VIDEO_TYPE
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.SUBMISSION_ID
import com.applicaster.plugin.televisionacademyplayer.network.ContentURLRepostory
import com.applicaster.plugin.televisionacademyplayer.network.OKHttpRepsotory
import com.applicaster.plugin_manager.login.LoginContract
import com.applicaster.plugin_manager.login.LoginManager
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.tvaplayerhook.enums.ResponseStatusCodes
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.listener.OnPlaybackFinishedListener
import com.bitmovin.player.api.event.listener.OnReadyListener
import com.bitmovin.player.cast.BitmovinCastManager
import com.bitmovin.player.config.media.SourceConfiguration
import com.bitmovin.player.config.media.SourceItem
import com.bitmovin.player.config.vr.VRContentType
import kotlinx.android.synthetic.main.activity_player.*
import kotlin.collections.ArrayList

class TAPlayerActivity : AppCompatActivity() {
    private var bitmovinPlayer: BitmovinPlayer? = null
    private var playable: Playable? = null
    private var currentProgress: Double = 0.0
    private var contentGroup: String = ""
    private val TAG = "TAPlayerActivity"
    private var bitmovinAnalyticInteractor: BitmovinAnalyticInteractor
    private var loginManager: LoginContract? = null
    private var playlistItems: List<Playable> = ArrayList()
    private var currentPlaylistItem = -1
    private var lastItemFinished = false
    private var videoType: String = ""
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

        loginManager = LoginManager.getLoginPlugin()
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window.setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        BitmovinCastManager.getInstance().updateContext(this)
        setContentView(R.layout.activity_player)

        intent.extras?.apply {
            playable = getSerializable(KEY_PLAYABLE) as? Playable
            contentGroup = getString(KEY_CONTENT_GROUP, "")
            videoType = getString(KEY_VIDEO_TYPE, "")
            currentProgress = getDouble(KEY_CURRENT_PROGRESS, 0.0)
            if (savedInstanceState != null) {
                currentProgress = savedInstanceState.getDouble(KEY_CURRENT_PROGRESS, 0.0)
                (savedInstanceState.getSerializable(KEY_PLAYABLE_LIST) as? Array<Playable>)?.toList()?.apply { playlistItems = this }
                (savedInstanceState.getSerializable(KEY_PLAYABLE) as Playable)?.apply { playable = this }
                currentPlaylistItem = savedInstanceState.getInt(KEY_NEXT_PLAYLIST_ITEM, -1)
            }
        }

        bitmovinPlayer = bitmovinPlayerView.player
        bitmovinAnalyticInteractor.initializeAnalyticsCollector(applicationContext, playable)
        bitmovinAnalyticInteractor.attachPlayer(bitmovinPlayer)
        bitmovinPlayer?.addEventListener(OnPlaybackFinishedListener {
            playNextItem()
        })
        bitmovinPlayer?.addEventListener(OnReadyListener {
            // if the currentProgress is near the end start play the video from the beginning
            if(((bitmovinPlayer!!.duration) - END_TIME_BUFFER <  currentProgress) && bitmovinPlayer!!.duration > END_TIME_BUFFER + 1) {
                playable?.setProgress(0.0)
                playable?.let { updatePlayable(it) }
                playItem()
            }

            bitmovinPlayer?.play()
        })

        if (playable != null && playable!!.contentVideoURL != null && currentPlaylistItem >= 0) {
            playItem()
        } else {
            playable?.takeIf { it is APURLPlayable && !loginManager?.token.isNullOrEmpty() }?.apply {
                val comp = (playable as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get(COMPETITION_ID) as? String ?: ""
                val sub = (playable as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get(SUBMISSION_ID) as? String ?: ""
                if (comp == "" || sub == ""){
                    playlistItems = listOf(playable!!)
                    getURL()
                }else{
                    getPlaylistItems(comp, sub,loginManager!!.token)
                }

            } ?: run { finish() }
        }


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

    private fun getURL() {
        for ((index, playable) in playlistItems.withIndex()) {
            ContentURLRepostory().contentUrl(playable.contentVideoURL, "Bearer ${loginManager!!.token}") { status, response ->
                if (status == ResponseStatusCodes.SUCCESS) {
                    playable.setContentVideoUrl(response)
                    if (index == 0) { // start playing when the first item return
                        playNextItem()
                    }
                } else {
                    finish()
                }
            }
        }
    }

    private fun getPlaylistItems(competition_id: String, submission_id: String, token: String) {
        OKHttpRepsotory().contentUIDS(competition_id, submission_id, token) { status, response ->
            if (status == ResponseStatusCodes.SUCCESS) {

                // rearrange list according to the current playable
                var orderedEntryLIst = (response?.entries ?: listOf()).toMutableList()
                var currentItemIndex = orderedEntryLIst.indexOfFirst { it.id == playable?.playableId}
                if(currentItemIndex != null) {
                    repeat(currentItemIndex) {
                        orderedEntryLIst.removeAt(0)
                    }
                }

                playlistItems = orderedEntryLIst.map { it.playable }

                getURL()
            } else {
                finish()
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putDouble(KEY_CURRENT_PROGRESS, bitmovinPlayer?.currentTime ?: 0.0)
        outState.putSerializable(KEY_PLAYABLE, playable)
        outState.putSerializable(KEY_PLAYABLE_LIST, playlistItems.toTypedArray())
        outState.putInt(KEY_NEXT_PLAYLIST_ITEM, currentPlaylistItem)
    }

    private fun playNextItem( ) {

        lastItemFinished = (currentPlaylistItem + 1) >= playlistItems.size
        if (lastItemFinished) {
            return
        }
        currentPlaylistItem += 1

        updatePlayable(playlistItems[currentPlaylistItem])

        playItem()
    }

    private fun playItem() {
        val sourceConfiguration = SourceConfiguration()
        if (videoType == "360") {
            val vrSourceItem = SourceItem(playable?.contentVideoURL)
            val vrConfiguration = vrSourceItem.vrConfiguration
            vrConfiguration.vrContentType = VRContentType.SINGLE
            vrConfiguration.startPosition = 180.0
            sourceConfiguration.addSourceItem(vrSourceItem)
        } else {
            sourceConfiguration.addSourceItem(playable!!.contentVideoURL)
        }
        sourceConfiguration.addSourceItem(playable!!.contentVideoURL)
        sourceConfiguration.startOffset = currentProgress
        bitmovinPlayer?.load(sourceConfiguration)
        EventListenerInteractor.addListeners(bitmovinPlayer, playable?.playableId
                ?: "", contentGroup)
        Log.d("TAPlayerActivity", "play now: " + currentPlaylistItem + " || current:" + currentProgress + " from total items:" + playlistItems.size)

    }

    private fun updatePlayable(playable: Playable) {
        this.playable = playable
        videoType = playable.getVideoType()
        contentGroup = playable.getContentGroup()
        currentProgress = playable.getProgress()
    }

    companion object {
        const val END_TIME_BUFFER = 5
        const val KEY_PLAYABLE_LIST = "KEY_PLAYABLE_LIST"
    }
}
