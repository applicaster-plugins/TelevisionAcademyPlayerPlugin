package com.applicaster.plugin.televisionacademyplayer.network

import com.google.gson.annotations.SerializedName

data class UIDSResponse(
        @SerializedName("entry")  val entry   : List<Entry>?
)
data class Entry(
        @SerializedName("content")  val content   : Content?

)
data class Content(
        val type: String,
        @SerializedName("src")  val src   :String?

)

