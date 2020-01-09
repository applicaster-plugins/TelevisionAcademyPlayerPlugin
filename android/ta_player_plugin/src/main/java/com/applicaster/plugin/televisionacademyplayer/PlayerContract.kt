package com.applicaster.plugin.televisionacademyplayer

import android.content.Context
import android.content.Intent
import android.view.ViewGroup
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.bitmovin.player.BitmovinPlayerView
import com.bitmovin.player.config.media.SourceConfiguration

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
    }

    override fun playInFullscreen(
        configuration: PlayableConfiguration?,
        requestCode: Int,
        context: Context
    ) {
        val intent = Intent(context, TAPlayerActivity::class.java)
        firstPlayable?.also {
            intent.putExtra(KEY_PLAYABLE, it)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(intent)
        }
    }

    override fun attachInline(viewGroup: ViewGroup) {
        super.attachInline(viewGroup)
        viewGroup.addView(videoView)
    }

    override fun removeInline(viewGroup: ViewGroup) {
        super.removeInline(viewGroup)
        viewGroup.removeView(videoView)
    }

    override fun playInline(configuration: PlayableConfiguration?) {
        super.playInline(configuration)
        firstPlayable.also {
            val source = SourceConfiguration()
            source.addSourceItem(it.contentVideoURL)
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
}