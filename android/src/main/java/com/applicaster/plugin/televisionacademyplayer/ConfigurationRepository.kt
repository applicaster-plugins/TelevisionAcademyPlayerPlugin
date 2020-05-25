package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val KEY_TEST_VIDEO_URL = "test_video_url"
    private val CHROMECAST_APP_ID = "chromecast_app_id"
    private val HEARTBEAT_INTERVAL = "heartbeat_interval"
    private val API_BASE_URL = "api_base_url"
    private val DSP_BASE_URL = "dsp_base_url"

    var testVideoUrl = ""
    var chromeCastAppId : String? = "F02DA75A"
    var heartbeatInterval: Int = 5000
    var apiBaseUrl: String ="https://api.view.televisionacademy.com/api/v1/"
    var dspBaseUrl: String ="https://zapp-pipes.herokuapp.com/emmys/"

    fun parseConfigurationFields(params: Map<*, *>) {
        params[KEY_TEST_VIDEO_URL]?.let {
            testVideoUrl = it.toString()
        }
        params[CHROMECAST_APP_ID]?.let {
            chromeCastAppId = it.toString()
        }
        params[API_BASE_URL]?.let {
            apiBaseUrl = it.toString()
        }
        params[DSP_BASE_URL]?.let {
            dspBaseUrl = it.toString()
        }
        params[HEARTBEAT_INTERVAL]?.let {
            it.toString().toIntOrNull()?.let { heartbeatIntervalValue ->
                heartbeatInterval = heartbeatIntervalValue
            }
        }
    }
}
