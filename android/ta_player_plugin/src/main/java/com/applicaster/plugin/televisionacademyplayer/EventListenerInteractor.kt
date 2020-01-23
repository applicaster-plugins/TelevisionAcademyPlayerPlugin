package com.applicaster.plugin.televisionacademyplayer


import com.applicaster.analytics.AnalyticsAgentUtil
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

    private val listeners = mutableListOf(
        object : OnPausedListener {
            override fun onPaused(event: PausedEvent) =
                AnalyticsAgentUtil.logPauseEvent(event.time.toLong())

        },
        object : OnPlayListener {
            override fun onPlay(event: PlayEvent) =
                AnalyticsAgentUtil.logPlayEvent(event.time.toLong())

        },
        object : OnSeekListener {
            override fun onSeek(event: SeekEvent) =
                AnalyticsAgentUtil.logSeekEndEvent(event.position.toInt())

        },
        object : OnErrorListener {
            override fun onError(event: ErrorEvent) =
                AnalyticsAgentUtil.handlePlayerError(event.message)
        }
    )

    fun addListeners(player: BitmovinPlayer?) {
        listeners.forEach { player?.addEventListener(it) }
    }

    fun removeListeners(player: BitmovinPlayer?) {
        listeners.forEach { player?.removeEventListener(it) }
    }
}