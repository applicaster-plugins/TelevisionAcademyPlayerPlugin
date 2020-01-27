package com.applicaster.plugin.televisionacademyplayer


import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.playerevents.PlayerEventsManager
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.api.event.data.ErrorEvent
import com.bitmovin.player.api.event.data.PausedEvent
import com.bitmovin.player.api.event.data.PlayEvent
import com.bitmovin.player.api.event.data.SeekEvent
import com.bitmovin.player.api.event.listener.OnErrorListener
import com.bitmovin.player.api.event.listener.OnPausedListener
import com.bitmovin.player.api.event.listener.OnPlayListener
import com.bitmovin.player.api.event.listener.OnSeekListener

object EventListenerInteractor {

    var contentId = ""
    var duration = 0.0

    private val listeners = mutableListOf(
        object : OnPausedListener {
            override fun onPaused(event: PausedEvent) {
                PlayerEventsManager.onPlayerEvent(
                    "pause",
                    hashMapOf(
                        Pair("elapsed_time", event.time),
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
                        Pair("elapsed_time", event.time),
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
                        Pair("elapsed_time", event.position),
                        Pair("content_length", duration),
                        Pair("content_uid", contentId)
                    )
                )
                AnalyticsAgentUtil.logSeekEndEvent(event.position.toInt())
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