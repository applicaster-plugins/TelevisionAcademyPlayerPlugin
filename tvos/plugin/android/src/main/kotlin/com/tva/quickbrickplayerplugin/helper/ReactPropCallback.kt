package com.tva.quickbrickplayerplugin.helper

import android.view.View
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter

class ReactPropCallback(val name: String) {

    fun call(view: View, arguments: WritableMap?) {

        val context = view.context as ReactContext

        context.getJSModule(RCTEventEmitter::class.java).receiveEvent(
                view.id,
                name,
                arguments
        )
    }
}