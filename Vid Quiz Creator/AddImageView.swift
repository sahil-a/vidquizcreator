//
//  AddImageView.swift
//  Vid Quiz Creator
//
//  Created by Sahil Ambardekar on 4/17/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class AddImageView: NSImageView {
    
    var delegate: AddImageViewDelegate?
    
    var questionField: NSTextField!
    var anwserOne: NSTextField!
    var anwserTwo: NSTextField!
    var anwserThree: NSTextField!
    var anwserFour: NSTextField!
    
    override func viewDidMoveToSuperview() {
        questionField = NSTextField(frame: NSRect(origin: CGPointMake(15, frame.height - 40), size: CGSizeMake(frame.width - 30, 28)))
        questionField.placeholderString = "Question"
        questionField.bordered = false
        questionField.wantsLayer = true
        questionField.layer?.masksToBounds = true
        questionField.layer?.cornerRadius = 3.0
        questionField.drawsBackground = true
        questionField.backgroundColor = NSColor(colorLiteralRed: 69 / 255, green: 97 / 255, blue: 134 / 255, alpha: 1)
        questionField.textColor = NSColor.whiteColor()
        questionField.alignment = .Center
        self.addSubview(questionField)
        
        anwserOne = NSTextField(frame: NSRect(origin: CGPointMake(15, frame.height - (30 * 2) - 10), size: CGSizeMake(frame.width - 30, 20)))

        anwserOne.placeholderString = "One"
        anwserOne.bordered = false
        anwserOne.wantsLayer = true
        anwserOne.layer?.masksToBounds = true
        anwserOne.layer?.cornerRadius = 3.0
        anwserOne.drawsBackground = true
        anwserOne.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1)

        anwserOne.textColor = NSColor.blackColor()
        anwserOne.alignment = .Center
        self.addSubview(anwserOne)
        
        anwserTwo = NSTextField(frame: NSRect(origin: CGPointMake(15, frame.height - (30 * 3) - 10), size: CGSizeMake(frame.width - 30, 20)))
        
        anwserTwo.placeholderString = "Two"
        anwserTwo.bordered = false
        anwserTwo.wantsLayer = true
        anwserTwo.layer?.masksToBounds = true
        anwserTwo.layer?.cornerRadius = 3.0
        anwserTwo.drawsBackground = true
        anwserTwo.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1)
        
        anwserTwo.textColor = NSColor.blackColor()
        anwserTwo.alignment = .Center
        self.addSubview(anwserTwo)
        
        anwserThree = NSTextField(frame: NSRect(origin: CGPointMake(15, frame.height - (30 * 4) - 10), size: CGSizeMake(frame.width - 30, 20)))
        
        anwserThree.placeholderString = "Three"
        anwserThree.bordered = false
        anwserThree.wantsLayer = true
        anwserThree.layer?.masksToBounds = true
        anwserThree.layer?.cornerRadius = 3.0
        anwserThree.drawsBackground = true
        anwserThree.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1)
        
        anwserThree.textColor = NSColor.blackColor()
        anwserThree.alignment = .Center
        self.addSubview(anwserThree)
        
        anwserFour = NSTextField(frame: NSRect(origin: CGPointMake(15, frame.height - (30 * 5) - 10), size: CGSizeMake(frame.width - 30, 20)))
        
        anwserFour.placeholderString = "Four"
        anwserFour.bordered = false
        anwserFour.wantsLayer = true
        anwserFour.layer?.masksToBounds = true
        anwserFour.layer?.cornerRadius = 3.0
        anwserFour.drawsBackground = true
        anwserFour.backgroundColor = NSColor(colorLiteralRed: 86 / 255, green: 124 / 255, blue: 173 / 255, alpha: 1)
        
        anwserFour.textColor = NSColor.blackColor()
        anwserFour.alignment = .Center
        self.addSubview(anwserFour)
        
        let confirmButton = NSButton(frame: NSRect(origin: CGPointMake(frame.width / 2 - 12, frame.height - (30 * 6) - 11), size: CGSizeMake(24, 24)))
        
        confirmButton.bordered = false
        confirmButton.image = NSImage(named: "done")
        confirmButton.setButtonType(.MomentaryChangeButton)
        confirmButton.wantsLayer = true
        confirmButton.layer?.backgroundColor = NSColor.clearColor().CGColor
        confirmButton.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.OnSetNeedsDisplay
        
        addSubview(confirmButton)
        
        confirmButton.target = self
        confirmButton.action = #selector(done)

        
    }
    
    func done() {
        
        delegate?.foundQuestion(VidQuiz.Question(question: questionField.stringValue , answers: [(anwserOne.stringValue, true), (anwserTwo.stringValue, false), (anwserThree.stringValue, false), (anwserFour.stringValue, false)]))
        
        self.removeFromSuperview()
    }

    override func drawRect(dirtyRect: NSRect) {
        lockFocus()
        super.drawRect(dirtyRect)
        unlockFocus()
        // Drawing code here.
        self.image = NSImage(named: "question")
    }
    
    
}

protocol AddImageViewDelegate {
    
    func foundQuestion(question: VidQuiz.Question)
}


