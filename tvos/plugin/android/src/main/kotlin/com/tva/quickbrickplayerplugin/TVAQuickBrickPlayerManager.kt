package com.tva.quickbrickplayerplugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import java.lang.ref.WeakReference


class TVAQuickBrickPlayerManager(context: ReactApplicationContext) : SimpleViewManager<TVAQuickBrickPlayerView>(), LifecycleEventListener {

    override fun getName(): String {
        return REACT_CLASS
    }


    private val reactContextWeakReference: WeakReference<ReactContext> = WeakReference(context)
    public override fun createViewInstance(context: ThemedReactContext): TVAQuickBrickPlayerView {
        if (context != null) {
            reactContextWeakReference.get()?.addLifecycleEventListener(this)
            Log.d(name, "" + "registerBroadcaster")
            this.registerBroadcaster(context)
        }
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
        const val RN_DURATION = "duration"
        const val RN_TIME = "time"
        const val RN_VIEW_ID = "rn_view_id"
        const val REACT_CLASS = "TVAQuickBrickPlayer"
        const val PROGRESS_EVENT = "progress_event"
    }


    private fun registerBroadcaster(context: Context) {
        val intentFilter = IntentFilter()
        intentFilter.addAction(PROGRESS_EVENT)
        LocalBroadcastManager.getInstance(context).registerReceiver(this.trackPlayerBroadcastReceiver, intentFilter)
    }


    private val trackPlayerBroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == PROGRESS_EVENT) {
                val info = Arguments.createMap()
                info.putDouble(RN_DURATION, intent.extras.getDouble(RN_DURATION))
                info.putDouble(RN_TIME, intent.extras.getDouble(RN_TIME))
                reactContextWeakReference.get()?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                        ?.emit("onVideoTimeChanged", info)
//                reactContextWeakReference.get()?.getJSModule(RCTEventEmitter::class.java)?.receiveEvent(
//                        intent.extras.getInt(RN_VIEW_ID), "onVideoTimeChanged", info)
                Log.d(name, "" + intent.extras.getDouble(RN_DURATION) + " || " + intent.extras.getDouble(RN_TIME))
            }
        }
    }

    override fun onHostResume() {

    }

    override fun onHostPause() {

    }

    override fun onHostDestroy() {
        var context = reactContextWeakReference.get()?.currentActivity
        if (context != null)
            LocalBroadcastManager.getInstance(context).unregisterReceiver(trackPlayerBroadcastReceiver)
    }


}
