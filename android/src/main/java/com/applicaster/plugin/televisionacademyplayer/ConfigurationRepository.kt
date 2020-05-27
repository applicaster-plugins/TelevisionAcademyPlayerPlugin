package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val CHROMECAST_APP_ID = "chromecast_app_id"
    private val HEARTBEAT_INTERVAL = "heartbeat_interval"
    private val API_BASE_URL = "api_base_url"
    private val DSP_BASE_URL = "dsp_base_url"
    private val DSP_PARAMETERS_URL = "dsp_parameters_url"

    var chromeCastAppId : String? = "F02DA75A"
    var heartbeatInterval: Int = 5000
    var apiBaseUrl: String ="https://api.view.televisionacademy.com/api/v1/"
    var dspBaseUrl: String ="https://zapp-pipes.herokuapp.com/emmys/fetchData"
    var dsp_parameters_url: String ="&type=submissions&screen=videos&env=prod&isTVApp=false"

    fun parseConfigurationFields(params: Map<*, *>) {
        params[CHROMECAST_APP_ID]?.let {
            chromeCastAppId = it.toString()
        }
        params[API_BASE_URL]?.let {
            apiBaseUrl = it.toString()
        }
        params[DSP_BASE_URL]?.let {
            dspBaseUrl = it.toString()
        }
        params[DSP_PARAMETERS_URL]?.let {
            dsp_parameters_url = it.toString()
        }
        params[HEARTBEAT_INTERVAL]?.let {
            it.toString().toIntOrNull()?.let { heartbeatIntervalValue ->
                heartbeatInterval = heartbeatIntervalValue
            }
        }
    }
}
