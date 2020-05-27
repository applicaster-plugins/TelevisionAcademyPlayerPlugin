package com.applicaster.plugin.televisionacademyplayer

import com.google.gson.annotations.SerializedName

data class PlaybackURLResponse(
        @SerializedName("playback_url")  val playback_url   : String?,
        @SerializedName("valid_until")   val valid_until    : String?
)