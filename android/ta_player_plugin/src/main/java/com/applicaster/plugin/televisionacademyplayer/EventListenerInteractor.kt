package com.applicaster.plugin.televisionacademyplayer


import android.util.Log
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.playerevents.PlayerEventsManager
import com.applicaster.plugin_manager.login.LoginManager
import com.applicaster.plugin_manager.playersmanager.Playable
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.data.*
import com.bitmovin.player.api.event.listener.*
import java.util.concurrent.TimeUnit

object EventListenerInteractor {
    
    private val TAG = "EventListenerInteractor" 

    var contentId = ""
    var contentGroup = ""
    val duration : Double
        get() =   player?.duration ?: 0.toDouble()


    var player: BitmovinPlayer? = null

    private val listeners = mutableListOf(
            object : OnPausedListener {
                override fun onPaused(event: PausedEvent) {
                    Log.d(TAG, "onPaused ${event.time.toLong()} sec")
                    PlayerEventsManager.onPlayerEvent(
                            "pause",
                            hashMapOf(
                                    Pair("playhead_position", event.time.toLong()),
                                    Pair("content_length", duration.toLong()),
                                    Pair("content_uid", contentId),
                                    Pair("content_group", contentGroup)
                            )
                    )

                    AnalyticsAgentUtil.logPauseEvent(event.time.toLong())
                }

            },
            object : OnPlayListener {
                override fun onPlay(event: PlayEvent) {
                    Log.d(TAG, "onPlay ${event.time.toLong()} sec")
                    PlayerEventsManager.onPlayerEvent(
                            "play",
                            hashMapOf(
                                    Pair("playhead_position", event.time.toLong()),
                                    Pair("content_length", duration.toLong()),
                                    Pair("content_uid", contentId),
                                    Pair("content_group", contentGroup)
                            )
                    )
                    AnalyticsAgentUtil.logPlayEvent(event.time.toLong())
                }

            },
            object : OnSeekListener {
                override fun onSeek(event: SeekEvent) {
                    Log.d(TAG, "onSeek ${event.seekTarget.toLong()} sec")
                    PlayerEventsManager.onPlayerEvent(
                            "seek",
                            hashMapOf(
                                    Pair("playhead_position", event.seekTarget.toLong()),
                                    Pair("content_length", duration.toLong()),
                                    Pair("content_uid", contentId),
                                    Pair("content_group", contentGroup)
                            )
                    )
                    AnalyticsAgentUtil.logSeekEndEvent(event.position.toInt())
                }

            },
            object : OnTimeChangedListener {

                var eventTimeStamp = System.currentTimeMillis()
                val TIME_OFFSET_IN_SEC = 4

                override fun onTimeChanged(event: TimeChangedEvent) {
                    val currentTimeMillis = System.currentTimeMillis()
                    val timeOffsetMin = TimeUnit.MILLISECONDS.toSeconds(currentTimeMillis - eventTimeStamp)
                    if (timeOffsetMin >= TIME_OFFSET_IN_SEC) {
                        Log.d(TAG, "onTimeChanged ${event.time.toLong()} sec")
                        PlayerEventsManager.onPlayerEvent(
                                "heartbeat",
                                hashMapOf(
                                        Pair("playhead_position", event.time.toLong()),
                                        Pair("content_length", duration.toLong()),
                                        Pair("content_uid", contentId),
                                        Pair("content_group", contentGroup)
                                )
                        )
                        eventTimeStamp = currentTimeMillis
                    }
                }
            },
            object : OnPlaybackFinishedListener {
                override fun onPlaybackFinished(event: PlaybackFinishedEvent?) {
                    Log.d(TAG, "onPlaybackFinished ${0} sec")
                    PlayerEventsManager.onPlayerEvent(
                            "heartbeat",
                            hashMapOf(
                                    Pair("playhead_position", 0),
                                    Pair("content_length", duration.toLong()),
                                    Pair("content_uid", contentId),
                                    Pair("content_group", contentGroup)
                            )
                    )
                }
            },
            object : OnErrorListener {
                override fun onError(event: ErrorEvent) {
                    AnalyticsAgentUtil.handlePlayerError(event.message)
                }
            }
    )

    fun addListeners(player: BitmovinPlayer?, contentId: String, contentGroup: String) {
        Log.d(TAG, "EventManager providers ${PlayerEventsManager.playerEventsProviders.size}")
        this.contentGroup = contentGroup
        this.contentId = contentId
        this.player = player
        listeners.forEach { player?.addEventListener(it) }
    }

    fun removeListeners(player: BitmovinPlayer?) {
        this.contentGroup = ""
        this.contentId = ""
        this.player = null
        listeners.forEach { player?.removeEventListener(it) }
    }
}