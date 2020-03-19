package com.tva.quickbrickplayerplugin.analytic

// Complete analytics events
enum class AnalyticEvent(val value: String) {
    PLAY_VOD_ITEM("Play VOD Item"),
    PLAY_LIVE_STREAM("Play Live Stream"),
    PAUSE("Pause"),
    SEEK("Seek")
}
