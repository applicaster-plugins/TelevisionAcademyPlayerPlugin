package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val KEY_TEST_VIDEO_URL = "test_video_url"
    private val CHROMECAST_APP_ID = "chromecast_app_id"
    private val HEARTBEAT_INTERVAL = "heartbeat_interval"

    var testVideoUrl = ""
    var chromeCastAppId : String? = "F02DA75A"
    var heartbeatInterval: Int = 5000

    fun parseConfigurationFields(params: Map<*, *>) {
        params[KEY_TEST_VIDEO_URL]?.let {
            testVideoUrl = it.toString()
        }
        params[CHROMECAST_APP_ID]?.let {
            chromeCastAppId = it.toString()
        }
        params[HEARTBEAT_INTERVAL]?.let {
            heartbeatInterval = it.toString().toInt()
        }
    }
}
