package com.applicaster.plugin.televisionacademyplayer

import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable

fun Playable.getProgress(): Double =
        (this as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get("playhead_position")?.toString()?.toDoubleOrNull()
                ?: 0.0

fun Playable.getContentGroup(): String =
        (this as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get("content_group")?.toString()
                ?: ""

fun Playable.getVideoType(): String =
(this as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.get("video_type")?.toString()
?: ""

fun Playable.setProgress(progress: Double) =
        (this as? APAtomEntry.APAtomEntryPlayable)?.entry?.extensions?.put("playhead_position", progress)