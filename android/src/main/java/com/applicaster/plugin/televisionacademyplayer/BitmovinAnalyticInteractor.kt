package com.applicaster.plugin.televisionacademyplayer

import android.content.Context
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.storage.LocalStorage
import com.applicaster.util.StringUtil
import com.bitmovin.analytics.BitmovinAnalyticsConfig
import com.bitmovin.analytics.bitmovin.player.BitmovinPlayerCollector
import com.bitmovin.analytics.enums.CDNProvider
import com.bitmovin.player.BitmovinPlayer

internal class BitmovinAnalyticInteractor {

    private var analyticsCollector: BitmovinPlayerCollector? = null

    fun initializeAnalyticsCollector(context: Context, playable: Playable?) {
        val bitmovinAnalyticsConfig = BitmovinAnalyticsConfig(
            context.getString(R.string.bitmovin_analytics_license_key),
            context.getString(R.string.bitmovin_player_license_key)
        )
        bitmovinAnalyticsConfig.heartbeatInterval = ConfigurationRepository.heartbeatInterval
        bitmovinAnalyticsConfig.videoId = playable?.playableId
        bitmovinAnalyticsConfig.cdnProvider = CDNProvider.BITMOVIN

        val userId = LocalStorage.storageRepository?.get("user_id","login")
        if (StringUtil.isNotEmpty(userId)) {
            bitmovinAnalyticsConfig.customUserId = userId
        }

        analyticsCollector = BitmovinPlayerCollector(bitmovinAnalyticsConfig, context)
    }

    fun attachPlayer(bitmovinPlayer: BitmovinPlayer?) {
        analyticsCollector?.attachPlayer(bitmovinPlayer)
    }

    fun detachPlayer() {
        analyticsCollector?.detachPlayer()
    }

}