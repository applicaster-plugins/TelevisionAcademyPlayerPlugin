package com.tva.quickbrickplayerplugin.quickbrickInterface

import com.facebook.react.common.MapBuilder
import com.tva.quickbrickplayerplugin.helper.ReactPropCallback

interface  ReactPropCallbacks {

    val reactCallbackPropNames: Array<String>
    val reactCallbackProps: MutableMap<String, ReactPropCallback>

    fun registerCallbackProps(): MutableMap<String, Any> {
        val builder = MapBuilder.builder<String, Any>()

        reactCallbackPropNames.forEach {
            val reactPropCallback = ReactPropCallback(it)
            reactCallbackProps.put(it, reactPropCallback)

            builder.put(
                    it,
                    MapBuilder.of<String, Any>(
                            "phasedRegistrationNames",
                            MapBuilder.of<String, String>(
                                    "bubbled",
                                    it
                            )
                    )
            )
        }

        return builder.build()
    }

    fun getReactCallback(name: String): ReactPropCallback? {
        return reactCallbackProps.get(name)
    }
}