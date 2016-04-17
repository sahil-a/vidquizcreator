//
//  ControlView.swift
//  Vid Quiz Creator
//
//  Created by Sahil Ambardekar on 4/17/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class ControlView: NSView, AddImageViewDelegate {
    
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var scrubArea: NSView!
    @IBOutlet weak var delegate: NSViewController?
    var scrubber: NSView!
    var dragging: Bool = false
    var paused: Bool = true
    var workingLoc: CGFloat = 0
    var adding: Bool = false
    
    func foundQuestion(question: VidQuiz.Question) {
        adding = false
        if let del = delegate as? ControlViewDelegate {
            
            del.addedQuestion(workingLoc, question: question)
        }
    }
    
    override func viewDidUnhide() {
        scrubber = NSView(frame: NSRect(origin: CGPointMake(scrubArea.frame.origin.x, scrubArea.frame.origin.y - 2.5), size: CGSizeMake(7, 37)))
              scrubber.wantsLayer = true
        scrubber.layer?.masksToBounds = false
        scrubber.layer?.cornerRadius = 4.0
        self.layer?.masksToBounds = false
        
        scrubber.layer?.backgroundColor = NSColor.whiteColor().CGColor
        addSubview(scrubber)
        
    } 

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        self.layer?.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1).CGColor
        scrubArea.layer?.backgroundColor = NSColor(colorLiteralRed: 69 / 255, green: 97 / 255, blue: 134 / 255, alpha: 1).CGColor
        scrubArea.layer?.masksToBounds = true
        scrubArea.layer?.cornerRadius = 4.0
        
    }
    
    func moveScrubberToLocation(loc: CGFloat) {
        
        scrubber.frame.origin.x = loc * (scrubArea.frame.width - 7) + 12
    }
    
    @IBAction func addPressed(sender: AnyObject) {
        let adder: AddImageView = AddImageView(frame: NSRect(origin: CGPointMake(scrubber.frame.origin.x+3.5-(307/2), scrubber.frame.origin.y + scrubber.frame.height), size: CGSizeMake(307, 217)))
        adder.image = NSImage(named:"question")
        adder.wantsLayer = true
        superview?.addSubview(adder)
        workingLoc = (scrubber.frame.origin.x - 12) / (scrubArea.frame.width - 7)
        adding = true
        adder.delegate = self
    }
    
    @IBAction func playPressed(sender: AnyObject) {
        if !adding {
        paused = !paused
        playButton.image = NSImage(named: (paused) ? "play": "pause")
        if let del = delegate as? ControlViewDelegate {
            
            (paused) ? del.pause():del.play()
        }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if !adding {
        let loc = theEvent.locationInWindow
        if CGRectContainsPoint(scrubArea.frame, loc) {
            moveScrubberToLocation((loc.x - 12) / (scrubArea.frame.width - 7))
            dragging = true
        }
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if dragging {
            if let del = delegate as? ControlViewDelegate {
                
                del.scrubToLocation((scrubber.frame.origin.x - 12) / (scrubArea.frame.width - 7))
            }
        }
        dragging = false
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        if !adding {
        if dragging {
            let loc = theEvent.locationInWindow
            if CGRectContainsPoint(NSRect(origin: CGPointMake(scrubArea.frame.origin.x, scrubArea.frame.origin.y - 500), size: CGSizeMake(scrubArea.frame.size.width, frame.size.height + 2000)), loc) {
                moveScrubberToLocation((loc.x - 12) / (scrubArea.frame.width - 7))
            } else {
                if loc.x < scrubArea.frame.origin.x {
                    
                    moveScrubberToLocation(0)
                } else {
                    
                    moveScrubberToLocation(1)
                }
            }
        }
        }
    }
    
}

protocol ControlViewDelegate {
    func pause()
    func play()
    func scrubToLocation(loc: CGFloat)
    func addedQuestion(loc: CGFloat, question: VidQuiz.Question)
}
