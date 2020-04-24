package com.tva.quickbrickplayerplugin.analytic

import android.content.Context
import com.bitmovin.analytics.BitmovinAnalyticsConfig
import com.bitmovin.analytics.bitmovin.player.BitmovinPlayerCollector
import com.bitmovin.analytics.enums.CDNProvider
import com.bitmovin.player.BitmovinPlayer
import com.tva.quickbrickplayerplugin.R

internal class BitmovinAnalyticInteractor {

    private var analyticsCollector: BitmovinPlayerCollector? = null

    fun initializeAnalyticsCollector(context: Context, sourceId: String?, heartbeatInterval: Int) {
        val bitmovinAnalyticsConfig = BitmovinAnalyticsConfig(
            context.getString(R.string.bitmovin_analytics_license_key),
            context.getString(R.string.bitmovin_player_license_key)
        )
        bitmovinAnalyticsConfig.heartbeatInterval = heartbeatInterval
        bitmovinAnalyticsConfig.videoId = sourceId
        bitmovinAnalyticsConfig.cdnProvider = CDNProvider.BITMOVIN

        analyticsCollector = BitmovinPlayerCollector(bitmovinAnalyticsConfig, context)
    }

    fun attachPlayer(bitmovinPlayer: BitmovinPlayer?) {
        analyticsCollector?.attachPlayer(bitmovinPlayer)
    }

    fun detachPlayer() {
        analyticsCollector?.detachPlayer()
    }

}