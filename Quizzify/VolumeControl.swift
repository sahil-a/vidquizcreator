//
//  VolumeControl.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/23/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class VolumeControl: NSView {
    
    private var levelView: NSView!
    private var backdropView: NSView!
    private let FULL = 131
    var delegate: VolumeControlDelegate?
    private var lastPercentile: Float = 1
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        backdropView = NSView(frame: NSRect(x: 0, y: 0, width: 21, height: FULL))
        backdropView.wantsLayer = true
        self.wantsLayer = true
        backdropView.layer?.backgroundColor = NSColor.whiteColor().colorWithAlphaComponent(0.11).CGColor
        addSubview(backdropView)
        backdropView.layer!.position = CGPointMake(frame.size.width/2 - 10.5, 0)
        backdropView.layer!.cornerRadius = 4
        backdropView.layer!.masksToBounds = true
        
        levelView = NSView(frame: NSRect(x: 0, y: 0, width: 21, height: FULL))
        levelView.wantsLayer = true
        levelView.layer?.backgroundColor = NSColor.whiteColor().CGColor
        backdropView.addSubview(levelView)
        levelView.layer!.position = CGPointMake(0, 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor(colorLiteralRed: 74 / 255, green: 106 / 255, blue: 146 / 255, alpha: 1).CGColor
        self.layer!.masksToBounds = false
        self.layer!.cornerRadius = 6.0
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let locInSelf = CGPointMake(loc.x - frame.origin.x, loc.y - frame.origin.y)
        if CGRectContainsPoint(self.frame, loc) {
            levelView.frame.size.height = locInSelf.y
            let percentile = locInSelf.y / frame.size.height
            delegate?.adjustedToPercentageLevel(Float(percentile))
            lastPercentile = Float(percentile)
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let loc = theEvent.locationInWindow
        let locInSelf = CGPointMake(loc.x - frame.origin.x, loc.y - frame.origin.y)
        if CGRectContainsPoint(self.frame, loc) {
            levelView.frame.size.height = locInSelf.y
            lastPercentile = Float(locInSelf.y / frame.size.height)
            delegate?.adjustedToPercentageLevel(Float(lastPercentile))
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        delegate?.adjustedToPercentageLevel(Float(lastPercentile))
    }
    
}

protocol VolumeControlDelegate {
    
    func adjustedToPercentageLevel(level: Float)
}
