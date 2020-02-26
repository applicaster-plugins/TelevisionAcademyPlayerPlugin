package com.applicaster.plugin.televisionacademyplayer


import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.playerevents.PlayerEventsManager
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.data.*
import com.bitmovin.player.api.event.listener.*
import java.util.concurrent.TimeUnit

object EventListenerInteractor {

    var contentId = ""
    var duration = 0.0

    private val listeners = mutableListOf(
            object : OnPausedListener {
                override fun onPaused(event: PausedEvent) {
                    PlayerEventsManager.onPlayerEvent(
                            "pause",
                            hashMapOf(
                                    Pair("playhead_position", event.time),
                                    Pair("content_length", duration),
                                    Pair("content_uid", contentId)
                            )
                    )
                    AnalyticsAgentUtil.logPauseEvent(event.time.toLong())
                }

            },
            object : OnPlayListener {
                override fun onPlay(event: PlayEvent) {
                    PlayerEventsManager.onPlayerEvent(
                            "play",
                            hashMapOf(
                                    Pair("playhead_position", event.time),
                                    Pair("content_length", duration),
                                    Pair("content_uid", contentId)
                            )
                    )
                    AnalyticsAgentUtil.logPlayEvent(event.time.toLong())
                }

            },
            object : OnSeekListener {
                override fun onSeek(event: SeekEvent) {
                    PlayerEventsManager.onPlayerEvent(
                            "seek",
                            hashMapOf(
                                    Pair("playhead_position", event.position),
                                    Pair("content_length", duration),
                                    Pair("content_uid", contentId)
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
                        PlayerEventsManager.onPlayerEvent(
                                "heartbeat",
                                hashMapOf(
                                        Pair("playhead_position", event.timestamp),
                                        Pair("content_length", duration),
                                        Pair("content_uid", contentId)
                                )
                        )
                        eventTimeStamp = currentTimeMillis
                    }
                }
            },
            object : OnPlaybackFinishedListener {
                override fun onPlaybackFinished(event: PlaybackFinishedEvent?) {
                        PlayerEventsManager.onPlayerEvent(
                            "heartbeat",
                            hashMapOf(
                                Pair("playhead_position", 0),
                                Pair("content_length", duration),
                                Pair("content_uid", contentId)
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

    fun addListeners(player: BitmovinPlayer?, contentId: String) {
        this.contentId = contentId
        this.duration = player?.duration ?: 0.0
        listeners.forEach { player?.addEventListener(it) }
    }

    fun removeListeners(player: BitmovinPlayer?) {
        this.contentId = ""
        this.duration = 0.0
        listeners.forEach { player?.removeEventListener(it) }
    }
}