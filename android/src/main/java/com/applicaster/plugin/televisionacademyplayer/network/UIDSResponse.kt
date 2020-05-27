package com.applicaster.plugin.televisionacademyplayer.network

import com.google.gson.annotations.SerializedName

data class UIDSResponse(
        @SerializedName("entry")  val entry   : List<Entry>?,
        val type: Type,
        val id: Long,
        val title: String,
        val extensions: WelcomeExtensions
)
data class Entry(
        @SerializedName("content")  val content   : Content?,
        val type: Type,
        val id: String,
        val title: String,
        val videoType: String,
        val summary: String,
        val mediaGroup: List<MediaGroup>,
        val extensions: EntryExtensions

)
data class Content(
        val type: String,
        @SerializedName("src")  val src   :String?

)

data class EntryExtensions (
        val contentGroup: String,
        val competitionID: String,
        val submissionID: String
)

data class MediaGroup (
        val type: String,
        val mediaItem: List<MediaItem>
)

data class MediaItem (
        val type: String,
        val key: String,
        val src: String
)

data class Type (
        val value: String
)

data class WelcomeExtensions (
        val executionTime: Long
)