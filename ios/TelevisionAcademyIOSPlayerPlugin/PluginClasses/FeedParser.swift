//
//  File.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Roman Karpievich on 5/25/20.
//

import Foundation
import ZappPlugins

class FeedParser {
    
    let token: String
    let video: ZPPlayable
    let dspBaseURL: String
    let tvaApiBaseURL: String
    let dspParameters: String
    
    init(video: ZPPlayable, dspBaseURL: String, tvaApiBaseURL: String, dspParameters: String) {
        let loginPluginsManager = ZAAppConnector.sharedInstance().pluginsDelegate?.loginPluginsManager
        self.token = loginPluginsManager?.createWithUserData()?.getUserToken() ?? ""
        self.video = video
        self.dspBaseURL = dspBaseURL
        self.tvaApiBaseURL = tvaApiBaseURL
        self.dspParameters = dspParameters
    }
    
    func parseVideos() -> [ZPPlayable] {
        guard let clickedVideoID = video.identifier,
            let request = createFeedContentRequest(from: video.extensionsDictionary) else {
                let video = parseSingleVideo()
                return [video]
        }
        
        let parseVideosDispatchGroup = DispatchGroup()
        
        parseVideosDispatchGroup.enter()
        
        var result: [ZPPlayable] = []
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let dspFeed = try? JSONDecoder().decode(DSPFeed.self, from: data) else {
                    parseVideosDispatchGroup.leave()
                    return
            }

            let entries = dspFeed.entry
            let clickedItemIndex = entries.firstIndex(where: { $0.id == clickedVideoID as String }) ?? 0
            let filteredEntries = entries.suffix(from: clickedItemIndex)

            let playableItems = filteredEntries.map { (entry) -> ZPPlayableItem in
                let playable = ZPPlayableItem()
                playable.name = entry.title
                playable.playDescription = entry.summary
                playable.videoURL = entry.content.src
                playable.live = false
                playable.identifier = entry.id as NSString

                let extensions = NSMutableDictionary()

                if let playheadPosition = entry.extensions.playheadPosition {
                    extensions["playhead_position"] = playheadPosition
                }
                extensions["content_group"] = entry.extensions.contentGroup

                playable.extensionsDictionary = extensions

                return playable
            }

            let parseURLGroup = DispatchGroup()
            
            for item in playableItems {
                parseURLGroup.enter()

                self.parseURL(for: item) { (url) in
                    item.videoURL = url
                    parseURLGroup.leave()
                }
            }
            
            parseURLGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
                result = playableItems
                parseVideosDispatchGroup.leave()
            }
            
        }.resume()
        
        parseVideosDispatchGroup.wait()
        
        return result
    }
    
    private func parseURL(for video: ZPPlayable, completion: @escaping (String) -> Void) {
        let session = URLSession.shared
        let url = URL(string: tvaApiBaseURL + "playback/" + video.contentVideoURLPath() + "?manifest_type=HLS")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request) { data, response, error in
            var result = ""
            if let data = data,
                let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let contentURL = responseDict["playback_url"] as? String {
                result = contentURL
            }
            
            completion(result)
        }.resume()
    }
    
    private func createFeedContentRequest(from config: NSDictionary?) -> URLRequest? {
        guard let submissionID = video.extensionsDictionary?["submission_id"] as? String,
            let competitionID = video.extensionsDictionary?["competition_id"] as? String,
            var components = URLComponents(string: "\(dspBaseURL)fetchData?\(dspParameters)") else {
                return nil
        }
        
        components.queryItems?.append(contentsOf: [URLQueryItem(name: "uid", value: submissionID),
                                                   URLQueryItem(name: "token", value: token),
                                                   URLQueryItem(name: "competitionId", value: competitionID)])
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }

    private func parseSingleVideo() -> ZPPlayable {
        let parseVideoDispatchGroup = DispatchGroup()
        parseVideoDispatchGroup.enter()
        
        let playable = ZPPlayableItem()
        playable.name = video.playableName()
        playable.playDescription = video.playableDescription()
        playable.videoURL = video.contentVideoURLPath()
        playable.live = video.isLive()
        playable.identifier = video.identifier
        playable.extensionsDictionary = video.extensionsDictionary

        parseURL(for: video) { (url) in
            playable.videoURL = url
            parseVideoDispatchGroup.leave()
        }
        
        parseVideoDispatchGroup.wait()
        
        return playable
    }
}

