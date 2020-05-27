package com.applicaster.plugin.televisionacademyplayer.network

import com.applicaster.plugin.televisionacademyplayer.PlaybackURLResponse
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Headers
import retrofit2.http.Path

interface NetworkAPI {

    @GET("playback/{content_uid}?manifest_type=HLS")
    @Headers("Accept: application/json")
    fun getPlaybackURL(@Path("content_uid") forContentId : String, @Header("Authorization") token : String) : Call<PlaybackURLResponse>
}