package com.applicaster.plugin.televisionacademyplayer

import android.content.Context
import android.content.Intent
import android.view.ViewGroup
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.model.APChannel
import com.applicaster.model.APVodItem
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.applicaster.plugin_manager.playersmanager.PlayerContract
import com.bitmovin.player.BitmovinPlayerView
import com.bitmovin.player.cast.BitmovinCastManager
import com.bitmovin.player.config.media.SourceConfiguration
import java.util.*

class PlayerContract : BasePlayer(), ApplicationLoaderHookUpI {

    companion object {
        const val KEY_PLAYABLE = "key_playable"
        const val KEY_CURRENT_PROGRESS = "KEY_CURRENT_PROGRESS"
    }

    lateinit var videoView: BitmovinPlayerView

    override fun init(playable: Playable, context: Context) {
        this.init(mutableListOf(playable), context)
    }

    override fun init(playableList: MutableList<Playable>, context: Context) {
        super.init(playableList, context)
        videoView = BitmovinPlayerView(context)
        initializeAnalyticsEvent()
    }

    override fun playInFullscreen(
            configuration: PlayableConfiguration?,
            requestCode: Int,
            context: Context
    ) {
        val intent = Intent(context, TAPlayerActivity::class.java)
        getContentPlayable().also {
            intent.putExtra(KEY_PLAYABLE, it)
            intent.putExtra(KEY_CURRENT_PROGRESS, getProgress(it))
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(intent)
        }
    }

    private fun getProgress(it: Playable?): Double =
            (it as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get("playhead_position")?.toString()?.toDoubleOrNull()
                    ?: 0.0

    private fun getContentGroup(it: Playable?): String =
            (it as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get("content_group")?.toString() ?: ""

    override fun attachInline(viewGroup: ViewGroup) {
        super.attachInline(viewGroup)
        viewGroup.addView(videoView)
        EventListenerInteractor.addListeners(videoView.player, firstPlayable.playableId, getContentGroup(firstPlayable))
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

    override fun getPlayerType() = PlayerContract.PlayerType.Default

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
        (playable as? APChannel)?.apply { params["Program Name"] = next_program.name }
        AnalyticsAgentUtil.generalPlayerInfoEvent(params)
        when {
            playable.isLive -> AnalyticsAgentUtil.PLAY_CHANNEL
            else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
        }.let { AnalyticsAgentUtil.endTimedEvent(it) }
    }

    override fun executeOnStartup(context: Context?, listener: HookListener?) {
        listener?.onHookFinished()
    }

    override fun executeOnApplicationReady(context: Context?, listener: HookListener?) {
        BitmovinCastManager.initialize()
        listener?.onHookFinished()
    }

}