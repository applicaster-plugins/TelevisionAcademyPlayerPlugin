package com.tva.quickbrickplayerplugin.api

import io.reactivex.Single
import retrofit2.http.Body
import retrofit2.http.PUT
import retrofit2.http.Path

interface WatchListApi {

    @PUT("/watchlist/{content_uid}")
    fun putWatchlist(@Path("content_uid") contentUid: String, @Body body: PlayerEvent): Single<Any>
}
