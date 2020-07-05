package com.applicaster.plugin.televisionacademyplayer

import android.content.Context
import android.content.Intent
import android.view.ViewGroup
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.model.APChannel
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.applicaster.plugin_manager.playersmanager.PlayerContract
import com.bitmovin.player.BitmovinPlayerView
import com.bitmovin.player.config.media.SourceConfiguration


class PlayerContract : BasePlayer(), ApplicationLoaderHookUpI {

    companion object {
        const val KEY_PLAYABLE = "key_playable"
        const val KEY_NEXT_PLAYLIST_ITEM = "key_next_Playlist_Item"
        const val KEY_CURRENT_PROGRESS = "KEY_CURRENT_PROGRESS"
        const val KEY_CONTENT_GROUP = "KEY_CONTENT_GROUP"
        const val COMPETITION_ID = "competition_id"
        const val SUBMISSION_ID = "submission_id"
        const val KEY_VIDEO_TYPE = "KEY_VIDEO_TYPE"
    }

    lateinit var videoView: BitmovinPlayerView
    private var bitmovinAnalyticInteractor: BitmovinAnalyticInteractor? = null

    override fun init(playable: Playable, context: Context) {
        this.init(mutableListOf(playable), context)
    }

    override fun init(playableList: MutableList<Playable>, context: Context) {
        super.init(playableList, context)
        videoView = BitmovinPlayerView(context)
        videoView.player?.config?.remoteControlConfiguration?.receiverStylesheetUrl = ConfigurationRepository.chromecastStyleCssUrl
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
            intent.putExtra(KEY_CURRENT_PROGRESS, it.getProgress())
            intent.putExtra(KEY_CONTENT_GROUP, it.getContentGroup())
            intent.putExtra(KEY_VIDEO_TYPE, it.getVideoType())
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(intent)
        }
    }

    override fun attachInline(viewGroup: ViewGroup) {
        super.attachInline(viewGroup)
        viewGroup.addView(videoView)
        bitmovinAnalyticInteractor = BitmovinAnalyticInteractor().apply {
            initializeAnalyticsCollector(context, getContentPlayable())
        }
        EventListenerInteractor.addListeners(videoView.player, firstPlayable.playableId, getContentPlayable().getContentGroup())
    }

    override fun removeInline(viewGroup: ViewGroup) {
        super.removeInline(viewGroup)
        viewGroup.removeView(videoView)
        bitmovinAnalyticInteractor?.detachPlayer()
        EventListenerInteractor.removeListeners(videoView.player)
    }

    override fun playInline(configuration: PlayableConfiguration?) {
        super.playInline(configuration)
        getContentPlayable().apply {
            val source = SourceConfiguration()
            source.addSourceItem(contentVideoURL)
            bitmovinAnalyticInteractor?.attachPlayer(videoView.player)
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

    private fun getContentPlayable(): Playable = firstPlayable


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
        listener?.onHookFinished()
    }
}
