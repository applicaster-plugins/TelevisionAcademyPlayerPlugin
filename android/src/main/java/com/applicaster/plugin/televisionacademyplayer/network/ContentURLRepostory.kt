package com.applicaster.plugin.televisionacademyplayer.network


import com.applicaster.plugin.televisionacademyplayer.PlaybackURLResponse
import com.applicaster.tvaplayerhook.enums.ResponseStatusCodes
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class ContentURLRepostory {


    fun contentUrl(forContentId: String, token: String, callback: (ResponseStatusCodes, String) -> Unit) {
        RestClient.getInstance().tvpClient.getPlaybackURL(forContentId, token).enqueue(object : Callback<PlaybackURLResponse> {
            override fun onResponse(call: Call<PlaybackURLResponse>, response: Response<PlaybackURLResponse>) {

                when (ResponseStatusCodes.getData(response.code())) {
                    ResponseStatusCodes.SUCCESS -> (response.body() as PlaybackURLResponse).playback_url?.let { callback(ResponseStatusCodes.SUCCESS, it) }
                    ResponseStatusCodes.AUTHENTICATION_FAILED -> callback(ResponseStatusCodes.AUTHENTICATION_FAILED, "")
                    ResponseStatusCodes.INVALID_REQUEST -> callback(ResponseStatusCodes.INVALID_REQUEST, "")
                    ResponseStatusCodes.NO_SUCH_CONTENT -> callback(ResponseStatusCodes.NO_SUCH_CONTENT, "")
                }
            }

            override fun onFailure(call: Call<PlaybackURLResponse>, t: Throwable) {
                callback(ResponseStatusCodes.ON_FAILURE_NO_CODE, t.message ?: "")
            }
        })
    }



}