package com.tva.quickbrickplayerplugin.analytic

import com.applicaster.analytics.AnalyticsAgentUtil

class AnalyticUtil {

    private companion object {
        const val TIMECODE_FROM = "Timecode From"
        const val TIMECODE_TO = "Timecode To"
        const val ITEM_DURATION = "Item Duration"
    }

    fun startTrack(time: Long, duration: Double) {
        AnalyticsAgentUtil.logTimedEvent(AnalyticEvent.PLAY_VOD_ITEM.value,
                mapOf(
                        TIMECODE_TO to time.toString(),
                        ITEM_DURATION to duration.toLong().toString())
        )
    }

    fun endTrack(time: Double, duration: Double) {
        AnalyticsAgentUtil.endTimedEvent(AnalyticEvent.PLAY_VOD_ITEM.value,
                mapOf(TIMECODE_TO to time.toLong().toString(),
                        ITEM_DURATION to duration.toLong().toString())
        )
    }

    fun trackPause(time: Double, duration: Double) {
        AnalyticsAgentUtil.logTimedEvent(
                AnalyticEvent.PAUSE.value,
                mapOf(TIMECODE_TO to time.toLong().toString(),
                        ITEM_DURATION to duration.toLong().toString())
        )
    }

    fun trackSeek(timeFrom: Double, timeTo: Double, duration: Double) {
        AnalyticsAgentUtil.logEvent(
                AnalyticEvent.SEEK.value,
                mapOf(
                        TIMECODE_FROM to timeFrom.toLong().toString(),
                        TIMECODE_TO to timeTo.toLong().toString(),
                        ITEM_DURATION to duration.toLong().toString()
                )
        )
    }

    fun handlePlayerError(message: String) {
        AnalyticsAgentUtil.handlePlayerError(message)
    }
}
