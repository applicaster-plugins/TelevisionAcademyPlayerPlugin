package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val KEY_TEST_VIDEO_URL = "test_video_url"
    private val CHROMECAST_APP_ID = "chromecast_app_id"

    var testVideoUrl = ""
    var chromeCastAppId : String? = "F02DA75A"

    fun parseConfigurationFields(params: Map<*, *>) {
        params[KEY_TEST_VIDEO_URL]?.let {
            testVideoUrl = it.toString()
        }
        params[CHROMECAST_APP_ID]?.let {
            chromeCastAppId = it.toString()
        }
    }
}
