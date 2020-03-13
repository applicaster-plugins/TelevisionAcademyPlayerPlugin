package com.tva.quickbrickplayerplugin.api

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import timber.log.Timber
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager


class ApiFactory(
        private val baseUrl: String,
        private val accessToken: String) {

    private val httpClient by lazy {
        OkHttpClient.Builder()
                .addInterceptor {
                    val original = it.request()
                    val request = original.newBuilder()
                            .header("Authorization", "Bearer $accessToken")
                            .header("Content-Type", "application/json")
                            .header("Accept", "application/json")
                            .method(original.method(), original.body())
                            .build()

                    it.proceed(request)
                }
                .addInterceptor(loggingInterceptor)
                .acceptUnsafe()
                .build()
    }

    private val loggingInterceptor
        get() = HttpLoggingInterceptor { Timber.d(it) }.setLevel(HttpLoggingInterceptor.Level.BODY)

    private val converter by lazy { GsonConverterFactory.create() }

    private val retrofit by lazy {
        Retrofit.Builder()
                .baseUrl(baseUrl)
                .client(httpClient)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(converter)
                .build()
    }

    val watchListApi: WatchListApi by lazy {
        retrofit
                .create(WatchListApi::class.java)
    }
}

private fun OkHttpClient.Builder.acceptUnsafe(): OkHttpClient.Builder {
    try {
        // Create a trust manager that does not validate certificate chains
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<java.security.cert.X509Certificate>, authType: String) {}
            override fun checkServerTrusted(chain: Array<java.security.cert.X509Certificate>, authType: String) {}
            override fun getAcceptedIssuers(): Array<java.security.cert.X509Certificate> = arrayOf()
        })

        // Install the all-trusting trust manager
        val sslContext = SSLContext.getInstance("SSL")
        sslContext.init(null, trustAllCerts, java.security.SecureRandom())

        // Create an ssl socket factory with our all-trusting manager
        val sslSocketFactory = sslContext.socketFactory

        this.sslSocketFactory(sslSocketFactory, trustAllCerts[0] as X509TrustManager)
        this.hostnameVerifier { _, _ -> true }
        return this
    } catch (e: Exception) {
        throw RuntimeException(e)
    }

}
