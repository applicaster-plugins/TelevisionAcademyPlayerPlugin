package com.tva.quickbrickplayerplugin.api

import android.util.Log
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

/**
 * Created by Barak Halevi on 01/06/2020.
 */
class VoidCallback<T> : Callback<T> {
    override fun onResponse(call: Call<T>, response: Response<T>) {
        Log.e("barak",response.toString())
    }
    override fun onFailure(call: Call<T>, t: Throwable) {}
}