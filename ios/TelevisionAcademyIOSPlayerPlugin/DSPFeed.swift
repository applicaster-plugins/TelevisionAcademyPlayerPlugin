// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dspfeed = try? newJSONDecoder().decode(DSPFeed.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct DSPFeed: Codable {
    let type: TypeClass
    let id: Int
    let title: String
    let entry: [Entry]
    let extensions: DSPFeedExtensions
}

// MARK: - Entry
struct Entry: Codable {
    let type: TypeClass
    let id, title, videoType, summary: String
    let mediaGroup: [MediaGroup]
    let content: Content
    let extensions: EntryExtensions

    enum CodingKeys: String, CodingKey {
        case type, id, title
        case videoType = "video_type"
        case summary
        case mediaGroup = "media_group"
        case content, extensions
    }
}

// MARK: - Content
struct Content: Codable {
    let type, src: String
}

// MARK: - EntryExtensions
struct EntryExtensions: Codable {
    let playheadPosition: Int?
    let submissionID: String
    let playNextFieldURL: String?
    let overlayTriggerTimestamp: Int?

    enum CodingKeys: String, CodingKey {
        case playheadPosition = "playhead_position"
        case submissionID = "submission_id"
        case playNextFieldURL = "play_next_field_url"
        case overlayTriggerTimestamp = "overlay_trigger_timestamp"
    }
}

// MARK: - MediaGroup
struct MediaGroup: Codable {
    let type: String
    let mediaItem: [MediaItem]

    enum CodingKeys: String, CodingKey {
        case type
        case mediaItem = "media_item"
    }
}

// MARK: - MediaItem
struct MediaItem: Codable {
    let type, key: String
    let src: String
}

// MARK: - TypeClass
struct TypeClass: Codable {
    let value: String
}

// MARK: - WelcomeExtensions
struct DSPFeedExtensions: Codable {
    let executionTime: Int
}
