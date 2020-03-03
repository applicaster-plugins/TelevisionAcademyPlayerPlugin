package com.tva.quickbrickplayerplugin.api

import com.google.gson.annotations.SerializedName

data class PlayerEvent(
        @SerializedName("content_length") val contentLengthInSeconds: Long,
        @SerializedName("playhead_position") val playheadPositionInSeconds: Long,
        @SerializedName("content_group") val contentGroup: String)
