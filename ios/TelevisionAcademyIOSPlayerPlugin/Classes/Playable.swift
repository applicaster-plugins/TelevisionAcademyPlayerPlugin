//
//  Playable.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 29.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappPlugins

class Playable: NSObject, ZPPlayable {

    static func createVASTVideo() -> ZPPlayable {
        let item = Playable()
        //        item.videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
        //        item.videoURL = "http://besttv61.aoslive.it.best-tv.com/reshet/applicaster/index.m3u8"
        item.videoURL = "http://199.203.217.171/xml_parsers/genre-videos/genre-videos-data/videos/comedy.mp4"
        item.name = "Test Video"
        item.free = false
        item.identifier = "123235245"
        item.extensionsDictionary = ["duration" : 12345]
        item.live = false

        // VAST
        let firstAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=",
                       "offset": "preroll"]
        let secondAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator=",
                        "offset": "postroll"]
        let thirdAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
                       "offset": "10"]
        let fourthAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
                        "offset": "90"]
        let ads = [firstAd, secondAd, thirdAd, fourthAd]
        let captions = self.captions()
        let extensionsDictionary: NSDictionary = ["free": "true",
                                                  "video_ads": ads,
                                                  "text_tracks": captions]
        item.extensionsDictionary = extensionsDictionary

        return item
    }

    static func captions() -> [String: Any] {
           let firstTrack = ["label": "English",
                             "type": "text/vtt",
                             "language": "en",
                             "source": "https://www.dropbox.com/s/cl9aowtpzfapmjc/raw_sintel_trailer_en.vtt.flat?dl=1",
                             "kind": "Captions"]

           let secondTrack = ["label": "French",
                              "type": "text/vtt",
                              "language": "fr",
                              "source": "https://www.dropbox.com/s/deoud5b59n886d7/raw_sintel_trailer_fr.vtt.flat?dl=1",
                              "kind": "Captions"]

           let tracks = [firstTrack, secondTrack]

           return ["version": "1.0",
                   "tracks": tracks]
       }


    public var name = ""
    public var playDescription = ""
    public var videoURL = ""
    public var overlayURL = ""
    public var live = false
    public var free = true
    public var publicPageURL = ""

    func playableName() -> String! {
        return name
    }

    func playableDescription() -> String! {
        return playDescription
    }

    func contentVideoURLPath() -> String! {
        return videoURL
    }

    func overlayURLPath() -> String! {
        return overlayURL
    }

    func isLive() -> Bool {
        return live
    }

    func isFree() -> Bool {
        return free
    }

    func publicPageURLPath() -> String! {
        return publicPageURL
    }

    func analyticsParams() -> [AnyHashable : Any]! {
        return [:]
    }

    func assetUrl() -> AVURLAsset? {
        return nil
    }

    var identifier: NSString?

    var extensionsDictionary: NSDictionary?
}
