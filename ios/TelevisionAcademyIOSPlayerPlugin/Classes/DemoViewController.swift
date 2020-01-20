//
//  DemoViewController.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 29.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import UIKit
import ZappPlugins

class DemoViewController: UIViewController {
    
    @IBOutlet  var inlineView: UIView!

    var plugin: BitmovinPlayerPlugin!
    
    @IBAction func buttonDemo() {

        let configurationJSON = ["test_video_url": "https://bitmovin.com/player-content/playhouse-vr/progressive.mp4"] as NSDictionary

        let playable = ZPPlayablItem.createVASTVideo()
        plugin = BitmovinPlayerPlugin.pluggablePlayerInit(playableItems: [playable], configurationJSON: configurationJSON) as! BitmovinPlayerPlugin
        plugin.presentPlayerFullScreen(self, configuration: nil, completion: nil)
//        plugin.pluggablePlayerAddInline(self, container: inlineView)
    }
}
