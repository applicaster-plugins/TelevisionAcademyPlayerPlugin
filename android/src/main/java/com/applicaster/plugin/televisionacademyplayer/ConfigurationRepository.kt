package com.applicaster.plugin.televisionacademyplayer

object ConfigurationRepository {

    private val CHROMECAST_APP_ID = "chromecast_app_id"
    private val HEARTBEAT_INTERVAL = "heartbeat_interval"
    private val API_BASE_URL = "api_base_url"
    private val DSP_BASE_URL = "dsp_base_url"
    private val DSP_PARAMETERS_URL = "dsp_parameters_url"
    private val CHROMECAST_STYLE_CSS_URL = "chromecast_style_css_url"

    var chromeCastAppId : String? = "F02DA75A"
    var heartbeatInterval: Int = 5000
    var apiBaseUrl: String ="https://api.view.televisionacademy.com/api/v1/"
    var dspBaseUrl: String ="https://zapp-pipes.herokuapp.com/emmys/fetchData"
    var dsp_parameters_url: String ="&type=submissions&screen=videos&env=prod&isTVApp=false"
    var chromecastStyleCssUrl : String? = "https://run.mocky.io/v3/a14c380b-3410-41ab-a85f-c4c5feb97cf6"

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
        params[CHROMECAST_STYLE_CSS_URL]?.let {
            chromecastStyleCssUrl = it.toString()
        }
    }
}
