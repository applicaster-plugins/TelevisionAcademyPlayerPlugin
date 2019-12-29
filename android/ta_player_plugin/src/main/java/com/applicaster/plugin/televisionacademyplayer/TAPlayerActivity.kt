package com.applicaster.plugin.televisionacademyplayer

import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import com.applicaster.plugin_manager.playersmanager.Playable
import com.bitmovin.player.BitmovinPlayer
import com.bitmovin.player.config.media.SourceConfiguration
import kotlinx.android.synthetic.main.activity_main.*

class TAPlayerActivity : AppCompatActivity() {

    private val KEY_CURRENT_PROGRESS = "KEY_CURRENT_PROGRESS"

    private var bitmovinPlayer: BitmovinPlayer? = null

    private var playable: Playable? = null
    private var currentProgress: Double = 0.0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        playable = with(intent) { extras?.getSerializable(PlayerContract.KEY_PLAYABLE) } as Playable
        if (savedInstanceState != null) {
            currentProgress = savedInstanceState.getDouble(KEY_CURRENT_PROGRESS, 0.0)
        }
        setContentView(R.layout.activity_main)
        bitmovinPlayer = bitmovinPlayerView.player
        initializePlayer()
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
        super.onPause()
    }

    override fun onStop() {
        bitmovinPlayerView.onStop()
        super.onStop()
    }

    override fun onDestroy() {
        bitmovinPlayerView.onDestroy()
        super.onDestroy()
    }

    private fun initializePlayer() {
        playable?.apply {
            val sourceConfiguration = SourceConfiguration()
            sourceConfiguration.addSourceItem(contentVideoURL)
            sourceConfiguration.startOffset = currentProgress
            bitmovinPlayer?.load(sourceConfiguration)
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putDouble(KEY_CURRENT_PROGRESS, bitmovinPlayer?.currentTime ?: 0.0)
    }
}