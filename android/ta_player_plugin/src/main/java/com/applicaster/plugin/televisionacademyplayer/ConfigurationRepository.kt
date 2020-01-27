package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val KEY_TEST_VIDEO_URL = "test_video_url"

    var testVideoUrl = ""

    fun parseConfigurationFields(params: Map<*, *>) {
        params[KEY_TEST_VIDEO_URL]?.let {
            testVideoUrl = it.toString()
        }
    }
}