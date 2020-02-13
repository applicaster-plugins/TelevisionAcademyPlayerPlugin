package com.tva.quickbrickplayerplugin

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class TVAQuickBrickPlayerManager(context: ReactApplicationContext) : SimpleViewManager<TVAQuickBrickPlayerView>() {

    override fun getName(): String {
        return REACT_CLASS
    }

    public override fun createViewInstance(context: ThemedReactContext): TVAQuickBrickPlayerView {
        return TVAQuickBrickPlayerView(context, null)
    }

    @ReactProp(name = "playableItem")
    fun setPlayableItem(view: TVAQuickBrickPlayerView, source: ReadableMap) {
        source.let { view.setPlayableItem(it) }
    }

    @ReactProp(name = "onKeyChanged")
    fun onKeyChanged(view: TVAQuickBrickPlayerView, event: ReadableMap?) {
        view.onKeyChanged(event)
    }

    @ReactProp(name = "pluginConfiguration")
    fun setPluginConfiguration(view: TVAQuickBrickPlayerView, configurations: ReadableMap) {
        println("pluginConfiguration " + configurations.toHashMap())
        view.setPluginConfiguration(configurations)
    }

    @ReactProp(name = "onSettingSelected")
    fun onSettingSelected(view: TVAQuickBrickPlayerView, params: ReadableMap) {
        view.onSettingSelected(params)
    }

    companion object {
        val REACT_CLASS = "TVAQuickBrickPlayer"
    }
}
