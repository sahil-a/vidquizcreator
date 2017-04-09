//
//  SpaceDetectingWindow.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/26/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class SpaceDetectingWindow: NSWindow {
    override func keyDown(theEvent: NSEvent) {
        let keysPressed: String? = theEvent.characters
        if let key = keysPressed {
            if (key == " ") {
                if theEvent.type == .KeyDown {
                    NSNotificationCenter.defaultCenter().postNotificationName("space", object: nil)
                }
            }
        } else {
            super.sendEvent(theEvent)

        }
        
    }
    override var acceptsFirstResponder: Bool { return true }
    override func becomeFirstResponder() -> Bool {
        return true
    }
}
