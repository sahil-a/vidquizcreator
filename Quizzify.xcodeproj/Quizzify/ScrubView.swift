//
//  ScrubView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/23/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class ScrubView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
        self.layer?.masksToBounds = true
        self.layer?.cornerRadius = 4.0
        layer!.shouldRasterize = true
        self.layer?.backgroundColor = NSColor(colorLiteralRed: 69 / 255, green: 97 / 255, blue: 134 / 255, alpha: 1).CGColor

    }
    
}
