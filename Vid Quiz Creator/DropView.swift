//
//  DropView.swift
//  Vid Quiz Creator
//
//  Created by Sahil Ambardekar on 4/16/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation

class DropView: NSView {
    
    @IBOutlet var delegate: NSViewController?
    
    override func viewDidMoveToWindow() {
        registerForDraggedTypes([NSFilenamesPboardType])
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Copy
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let file = (sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String])[0]
        let asset = AVURLAsset(URL: NSURL(string: "file://" + file)!)
        if let d = delegate as? DropViewDelegate {
            d.foundAsset(asset)
        }
        return true
    }
}

protocol DropViewDelegate {
    
    func foundAsset(asset: AVAsset)
}
