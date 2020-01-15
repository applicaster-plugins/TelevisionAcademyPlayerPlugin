package com.tva.quickbrickplayerplugin

import com.applicaster.plugin_manager.GenericPluginI
import com.applicaster.plugin_manager.Plugin

class QuickBrickPlayerPlugin: GenericPluginI {
    var plugin :  Plugin? = null
    override fun setPluginModel(plugin: Plugin?) {
        this.plugin = plugin
    }

}

