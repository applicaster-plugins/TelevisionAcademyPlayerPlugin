package com.applicaster.plugin.televisionacademyplayer.network

import com.applicaster.plugin.televisionacademyplayer.PlaybackURLResponse
import retrofit2.Call
import retrofit2.http.*

interface NetworkAPI {

    @GET("playback/{content_uid}?manifest_type=HLS")
    @Headers("Accept: application/json")
    fun getPlaybackURL(@Path("content_uid") forContentId : String, @Header("Authorization") token : String) : Call<PlaybackURLResponse>

    @GET("fetchData?type=submissions&screen=videos&env=prod&isTVApp=false")
    @Headers("Accept: application/json")
    fun getUIDs(@Query("competition_id") competition_id : String, @Query("uid") submission_id : String, @Query("token") token : String) : Call<UIDSResponse>

}