package com.applicaster.plugin.televisionacademyandroidplayer

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import com.applicaster.plugin.televisionacademyplayer.PlayerContract

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        PlayerContract().playInFullscreen(null, 0, this)
    }
}
