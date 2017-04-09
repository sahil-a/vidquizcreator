//
//  DropView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/24/16.
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
        let file = (sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String])[0]
        if file.hasSuffix("mov") || file.hasSuffix("avi") || file.hasSuffix("mpg") || file.hasSuffix("mp4") {
            return NSDragOperation.Copy
        }
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let file = (sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! [String])[0]
        Swift.print(file)
        let asset = AVURLAsset(URL: NSURL(string: "file://" + file)!)
        // doesnt work w/spaces
        asset.loadValuesAsynchronouslyForKeys(["tracks"]) { 
            if asset.tracks.count > 0 {
                
                if let d = self.delegate as? DropViewDelegate {
                    dispatch_async(dispatch_get_main_queue()) {
                        d.foundAsset(asset)
                    }
                }
            }
        }
        return true
    }
}

protocol DropViewDelegate {
    
    func foundAsset(asset: AVAsset)
}