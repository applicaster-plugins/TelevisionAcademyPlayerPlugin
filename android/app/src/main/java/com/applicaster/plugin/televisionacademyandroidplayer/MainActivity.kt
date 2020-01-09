package com.applicaster.plugin.televisionacademyandroidplayer

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import com.applicaster.model.APVodItem
import com.applicaster.plugin.televisionacademyplayer.PlayerContract
import com.digiflare.tva.viewing.R
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        btn_start.setOnClickListener {
            PlayerContract().apply {
                val playable = APVodItem()
                playable.stream_url =
                    "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd"
                init(playable, applicationContext)
                playInFullscreen(null, 0, applicationContext)
            }
        }
    }
}
