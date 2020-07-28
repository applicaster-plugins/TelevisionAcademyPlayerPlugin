package com.tva.quickbrickplayerplugin

class VideoPlayerEvents {

    companion object {

        /**
         * event names - named of react function props
         */
        const val eventVideoStart = "eventVideoStart"
        const val eventVideoPause = "eventVideoPause"
        const val eventLoadStart = "onVideoLoadStart"
        const val eventLoad = "onVideoLoad"
        const val eventError = "onVideoError"
        const val eventProgress = "onVideoProgress"
        const val eventBandwidth = "onVideoBandwidthUpdate"
        const val eventSeek = "onVideoSeek"
        const val eventEnd = "onVideoEnd"
        const val eventFullscreenWithPresend = "onVideoFullscreenPlayerWillPresent"
        const val eventFullscreenDidPresent = "onVideoFullscreenPlayerDidPresent"
        const val eventFullscreenWillDismiss = "onVideoFullscreenPlayerWillDismiss"
        const val eventFullscreenDidDismiss = "onVideoFullscreenPlayerDidDismiss"
        const val eventStalled = "onPlaybackStalled"
        const val eventResume = "onPlaybackResume"
        const val eventReady = "onReadyForDisplay"
        const val eventBuffer = "onVideoBuffer"
        const val eventIdle = "onVideoIdle"
        const val eventTimedMetadata = "onTimedMetadata"
        const val eventAudioBecomingNoisy = "onVideoAudioBecomingNoisy"
        const val eventAudioFocusChange = "onAudioFocusChanged"
        const val eventPlaybackRateChange = "onPlaybackRateChange"
        const val eventExternalPlaybackChange = "eventExternalPlaybackChange"

        /**
         *  @return list of Event for JS to receive
         */
        fun getListOfEvent(): Array<String> {
            return arrayOf(
                    eventVideoPause,
                    eventVideoStart,
                    eventLoad,
                    eventLoadStart,
                    eventError,
                    eventProgress,
                    eventBandwidth,
                    eventSeek,
                    eventEnd,
                    eventFullscreenWithPresend,
                    eventFullscreenDidPresent,
                    eventFullscreenWillDismiss,
                    eventFullscreenDidDismiss,
                    eventStalled,
                    eventResume,
                    eventReady,
                    eventBuffer,
                    eventIdle,
                    eventTimedMetadata,
                    eventAudioBecomingNoisy,
                    eventAudioFocusChange,
                    eventPlaybackRateChange,
                    eventExternalPlaybackChange
            )
        }


        const val payloadPropPlaybackRate = "rate"
        const val payloadPropIsExternalPlaybackActive = "isExternalPlayBackActive"
        const val payloadPropCurrentTime = "currentTime"
        const val payloadPropSeekTime = "seekTime"
        const val payloadPropHasAudioFocus = "hasAudioFocus"
        const val payloadPropPlayableDuration = "playableDuration"
        const val payloadPropSeekableDuration = "seekableDuration"
        const val payloadPropError = "error"
        const val payloadPropDuration = "duration"
        const val payloadPropCurrentPosition = "currentPosition"
        const val payloadPropVideoWidth = "videoWidth"
        const val payloadPropVideoHeight = "videoHeight"
        const val payloadPropAudioTracks = "audioTracks"
        const val payloadPropTextTracks = "textTracks"
    }
}