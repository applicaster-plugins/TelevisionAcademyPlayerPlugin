package com.applicaster.plugin.televisionacademyplayer

import android.content.Context
import android.content.Intent
import android.view.ViewGroup
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.model.APChannel
import com.applicaster.model.APVodItem
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.bitmovin.player.BitmovinPlayerView
import com.bitmovin.player.config.media.SourceConfiguration
import java.util.*

class PlayerContract : BasePlayer() {

    companion object {
        const val KEY_PLAYABLE = "key_playable"
    }

    lateinit var videoView: BitmovinPlayerView

    override fun init(playable: Playable, context: Context) {
        this.init(mutableListOf(playable), context)
    }

    override fun init(playableList: MutableList<Playable>, context: Context) {
        super.init(playableList, context)
        videoView = BitmovinPlayerView(context)
//        TODO: Uncomment it if needed more analytic data
//        initializeAnalyticsEvent()
    }

    override fun playInFullscreen(
        configuration: PlayableConfiguration?,
        requestCode: Int,
        context: Context
    ) {
        val intent = Intent(context, TAPlayerActivity::class.java)
        getContentPlayable().also {
            intent.putExtra(KEY_PLAYABLE, it)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(intent)
        }
    }

    override fun attachInline(viewGroup: ViewGroup) {
        super.attachInline(viewGroup)
        viewGroup.addView(videoView)
        EventListenerInteractor.addListeners(videoView.player, firstPlayable.playableId)
    }

    override fun removeInline(viewGroup: ViewGroup) {
        super.removeInline(viewGroup)
        viewGroup.removeView(videoView)
        EventListenerInteractor.removeListeners(videoView.player)
    }

    override fun playInline(configuration: PlayableConfiguration?) {
        super.playInline(configuration)
        getContentPlayable().apply {
            val source = SourceConfiguration()
            source.addSourceItem(contentVideoURL)
            videoView.player?.config?.playbackConfiguration?.isAutoplayEnabled = true
            videoView.player?.load(source)
        }
    }

    override fun stopInline() {
        super.stopInline()
        videoView.onStop()
    }

    override fun pause() {
        super.pause()
        videoView.onPause()
    }

    override fun pauseInline() {
        super.pauseInline()
        videoView.onPause()
    }

    override fun resumeInline() {
        super.resumeInline()
        videoView.onResume()
    }

    override fun setPluginConfigurationParams(params: Map<*, *>) {
        super.setPluginConfigurationParams(params)
        ConfigurationRepository.parseConfigurationFields(params)
    }

    private fun getContentPlayable(): Playable =
        if (ConfigurationRepository.testVideoUrl.isEmpty()) {
            firstPlayable
        } else {
            val item = APVodItem()
            item.stream_url = ConfigurationRepository.testVideoUrl
            item
        }

    private fun initializeAnalyticsEvent() {
        val playable = getContentPlayable()
        val params = playable.analyticsParams
        try {
            val channel = playable as APChannel
            params["Program Name"] = channel.next_program.name
        } catch (e: ClassCastException) {
            e.printStackTrace()
        } catch (e: NullPointerException) {
            e.printStackTrace()
        }

        AnalyticsAgentUtil.generalPlayerInfoEvent(params)
        when {
            playable.isLive -> AnalyticsAgentUtil.PLAY_CHANNEL
            else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
        }.let { AnalyticsAgentUtil.endTimedEvent(it) }
    }
}