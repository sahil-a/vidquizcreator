//
//  PlaybarView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/23/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class PlaybarView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
        self.layer?.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1).CGColor
        self.layer?.shadowColor = NSColor.blackColor().CGColor
        self.layer?.shadowOpacity = 0.25
        self.layer?.shadowRadius = 4
        self.layer?.shadowOffset = CGSizeMake(0, 3)
        self.layer?.masksToBounds = false
    }
}
