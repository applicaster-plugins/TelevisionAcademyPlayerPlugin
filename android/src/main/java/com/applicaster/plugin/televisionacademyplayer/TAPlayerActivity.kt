package com.applicaster.plugin.televisionacademyplayer

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
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_QUEUE
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.KEY_URL
import com.applicaster.plugin.televisionacademyplayer.PlayerContract.Companion.SUBMISSION_ID
import com.applicaster.plugin.televisionacademyplayer.network.ContentURLRepostory
import com.applicaster.plugin.televisionacademyplayer.network.Entry
import com.applicaster.plugin_manager.login.LoginContract
import com.applicaster.plugin_manager.login.LoginManager
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.tvaplayerhook.enums.ResponseStatusCodes
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.listener.OnPlaybackFinishedListener
import com.bitmovin.player.api.event.listener.OnReadyListener
import com.bitmovin.player.cast.BitmovinCastManager
import com.bitmovin.player.config.media.SourceConfiguration
import kotlinx.android.synthetic.main.activity_player.*
import java.util.*
import kotlin.collections.ArrayList

class TAPlayerActivity : AppCompatActivity() {


    private var bitmovinPlayer: BitmovinPlayer? = null
    private var playable: Playable? = null
    private var currentProgress: Double = 0.0
    private var contentGroup: String = ""
    private val TAG = "TAPlayerActivity"
    private var bitmovinAnalyticInteractor: BitmovinAnalyticInteractor
    private var loginManager: LoginContract? = null
    private var uidList: LinkedList<String> = LinkedList()
    private var playlistItems: ArrayList<String> = ArrayList()
    private var currentPlaylistItem = -1
    private var lastItemFinished = false

    init {
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
//        pBar.visibility = View.VISIBLE

        intent.extras?.apply {
            playable = getSerializable(KEY_PLAYABLE) as? Playable
            (getSerializable(KEY_QUEUE) as? LinkedList<String>)?.apply {
                uidList = this
            }
            currentProgress = getDouble(KEY_CURRENT_PROGRESS, 0.0)
            if (savedInstanceState != null) {
                currentProgress = savedInstanceState.getDouble(KEY_CURRENT_PROGRESS, 0.0)
                (savedInstanceState.getSerializable(KEY_URL) as ArrayList<String>)?.apply { playlistItems = this }
                (savedInstanceState.getSerializable(KEY_QUEUE) as LinkedList<String>)?.apply { uidList = this }
                (savedInstanceState.getSerializable(KEY_PLAYABLE) as Playable)?.apply { playable = this }
                currentPlaylistItem = savedInstanceState.getInt(KEY_NEXT_PLAYLIST_ITEM, -1)
                uidList.poll().takeIf { !it.isNullOrEmpty() }?.apply {
                    loginManager?.token?.let { getURL(this, it) }
                }
            }
            contentGroup = getString(KEY_CONTENT_GROUP, "")
        }
        bitmovinPlayer = bitmovinPlayerView.player
        bitmovinAnalyticInteractor.initializeAnalyticsCollector(applicationContext, playable)
        bitmovinAnalyticInteractor.attachPlayer(bitmovinPlayer)
        if (playable != null && playable!!.contentVideoURL != null && currentPlaylistItem >= 0) {
            playNextItem(true)

        } else {
            playable?.takeIf { it is APURLPlayable && !loginManager?.token.isNullOrEmpty() }?.apply {
                getUIDs(
                        (playable as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get(COMPETITION_ID) as? String
                                ?: playable!!.contentVideoURL,
                        (playable as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get(SUBMISSION_ID) as? String
                                ?: playable!!.contentVideoURL,
                        loginManager!!.token)
            } ?: run { finish() }
        }

        bitmovinPlayer?.addEventListener(OnPlaybackFinishedListener {
            currentProgress = 0.0
            playNextItem(false)
        })
        bitmovinPlayer?.addEventListener(OnReadyListener {
            pBar.visibility = View.GONE
            bitmovinPlayer?.play()
        })
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

    private fun getURL(id: String, token: String) {
        ContentURLRepostory().contentUrl(id, "Bearer $token") { status, response ->
            if (status == ResponseStatusCodes.SUCCESS) {
                playlistItems.add(response)
                if (currentPlaylistItem < 0) {
                    playNextItem(false)
                }
                uidList.poll().takeIf { !it.isNullOrEmpty() }?.apply {
                    loginManager?.token?.let { getURL(this, it) }
                }
            } else {
                finish()
            }
        }
    }

    private fun getUIDs(competition_id: String, submission_id: String, token: String) {
        ContentURLRepostory().contentUIDS(competition_id, submission_id, token) { status, response ->
            if (status == ResponseStatusCodes.SUCCESS) {
                for (episode: Entry in response?.entry!!) {
                    episode.content!!.src?.let { uidList.add(it) }
                }
                uidList.poll().takeIf { !it.isNullOrEmpty() }?.apply {
                    loginManager?.token?.let { getURL(this, it) }
                }
            } else {
                finish()
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putDouble(KEY_CURRENT_PROGRESS, bitmovinPlayer?.currentTime ?: 0.0)
        outState.putSerializable(KEY_PLAYABLE, playable)
        outState.putSerializable(KEY_URL, playlistItems)
        outState.putSerializable(KEY_QUEUE, uidList)
        outState.putInt(KEY_NEXT_PLAYLIST_ITEM, currentPlaylistItem)
    }

    private fun playNextItem(playAfterRotation: Boolean) {
        if (!playAfterRotation) {
            lastItemFinished = (currentPlaylistItem + 1) >= playlistItems.size
            if (lastItemFinished) {
                return
            }
            currentPlaylistItem += 1
        }
        playable!!.setContentVideoUrl(this.playlistItems[currentPlaylistItem])
        val sourceConfiguration = SourceConfiguration()
        sourceConfiguration.addSourceItem(playable!!.contentVideoURL)
        sourceConfiguration.startOffset = currentProgress
        bitmovinPlayer?.load(sourceConfiguration)
        EventListenerInteractor.addListeners(bitmovinPlayer, playable?.playableId
                ?: "", contentGroup)
        Log.e(TAG, "play now: " + currentPlaylistItem + " || current:" + currentProgress + " from total items:" + playlistItems.size)
    }
}
