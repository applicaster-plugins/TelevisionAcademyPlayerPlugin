package com.tva.quickbrickplayerplugin.helper

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap

class ReactArgumentsBuilder {

    private val arguments = Arguments.createMap()

    fun putString(key: String, value: String): ReactArgumentsBuilder {
        arguments.putString(key, value)
        return this
    }

    fun putDouble(key: String, value: Double): ReactArgumentsBuilder {
        arguments.putDouble(key, value)
        return this
    }

    fun putInt(key: String, value: Int): ReactArgumentsBuilder {
        arguments.putInt(key, value)
        return this
    }

    fun putArray(key: String, value: WritableArray) : ReactArgumentsBuilder {
        arguments.putArray(key, value)
        return this
    }

    fun putBoolean(key: String, value: Boolean) : ReactArgumentsBuilder {
        arguments.putBoolean(key, value)
        return this
    }

    fun putMap(key: String, value: WritableMap): ReactArgumentsBuilder {
        arguments.putMap(key, value)
        return this
    }

    fun build(): WritableMap {
        return arguments
    }
}