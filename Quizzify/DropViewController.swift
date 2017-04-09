//
//  DropViewController.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/24/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation

class DropViewController: NSViewController, DropViewDelegate {
    
    var asset: AVAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func foundAsset(asset: AVAsset) {
        self.asset = asset
        (self.parentViewController! as! Mediator).picked()
    }
}
