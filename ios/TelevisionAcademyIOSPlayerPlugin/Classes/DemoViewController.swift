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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonDemo() {
        let playable = Playable.createVASTVideo()
        plugin = BitmovinPlayerPlugin.pluggablePlayerInit(playableItems: [playable], configurationJSON:[:]) as! BitmovinPlayerPlugin
        plugin.presentPlayerFullScreen(self, configuration: nil, completion: nil)
    }
}
