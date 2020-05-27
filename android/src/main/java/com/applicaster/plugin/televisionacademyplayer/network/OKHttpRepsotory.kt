package com.applicaster.plugin.televisionacademyplayer.network

import com.applicaster.plugin.televisionacademyplayer.ConfigurationRepository
import com.applicaster.plugin.televisionacademyplayer.ConfigurationRepository.dsp_parameters_url
import com.applicaster.tvaplayerhook.enums.ResponseStatusCodes
import com.google.gson.Gson
import okhttp3.*
import java.io.IOException


/**
 * Created by Barak Halevi on 26/05/2020.
 */
class OKHttpRepsotory {
    fun contentUIDS( competition_id: String,submission_id: String, token: String, callback: (ResponseStatusCodes, UIDSResponse?) -> Unit) {
        val urlBuilder = HttpUrl.parse(ConfigurationRepository.dspBaseUrl)!!.newBuilder()
        urlBuilder.addQueryParameter("competition_id", competition_id)
        urlBuilder.addQueryParameter("uid", submission_id)
        urlBuilder.addQueryParameter("token", token)
        val url = urlBuilder.build().toString()+dsp_parameters_url
        val request = Request.Builder().url(url).build()
        OkHttpClient().newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback(ResponseStatusCodes.ON_FAILURE_NO_CODE, null)
            }
            override fun onResponse(call: Call, response: Response) {
                val body = response.body()
                val bodyString = body?.string() ?: ""
                if ((response.code()==200) && bodyString.length>2) {
                    callback(ResponseStatusCodes.SUCCESS, Gson().fromJson(bodyString, UIDSResponse::class.java))
                }
                else{
                    callback(ResponseStatusCodes.AUTHENTICATION_FAILED, null)
                }
            }
        })
    }
}