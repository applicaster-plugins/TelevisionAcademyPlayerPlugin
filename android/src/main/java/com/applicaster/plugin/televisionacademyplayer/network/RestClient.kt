package com.applicaster.plugin.televisionacademyplayer.network

import com.applicaster.plugin.televisionacademyplayer.ConfigurationRepository.apiBaseUrl
import com.applicaster.plugin.televisionacademyplayer.ConfigurationRepository.dspBaseUrl
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

class RestClient {

    private val TIME_OUT: Short = 15000

    companion object {
        @Volatile
        private var instanse: RestClient? = null
        fun getInstance() = instanse
                ?: synchronized(this) {
            instanse
                    ?: RestClient().also { instanse = it }
        }
    }


    private val okHttpClient =
        OkHttpClient.Builder().connectTimeout(TIME_OUT.toLong(), TimeUnit.MILLISECONDS).build()


    private val retrofit = Retrofit.Builder()
        .baseUrl(apiBaseUrl)
        .addConverterFactory(GsonConverterFactory.create())
        .client(okHttpClient)
        .build()

    var tvpClient = retrofit.create<NetworkAPI>(NetworkAPI::class.java)

    private val DSPRetrofit = Retrofit.Builder()
        .baseUrl(dspBaseUrl)
        .addConverterFactory(GsonConverterFactory.create())
        .client(okHttpClient)
        .build()


    var DSPClient = DSPRetrofit.create<NetworkAPI>(NetworkAPI::class.java)


}