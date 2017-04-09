//
//  CellView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 5/1/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class CellView: NSView {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var answerLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    var name: String = "" {
        didSet {
            nameLabel.stringValue = name
        }
    }
    
    var answer: String = "" {
        didSet {
            answerLabel.stringValue = answer
        }
    }
    
    var correct: Bool = true {
        didSet {
            imageView.image = NSImage(named: (correct) ? "correct" : "incorrect")
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        wantsLayer = true
        layer?.backgroundColor = NSColor(colorLiteralRed: 131 / 255, green: 149 / 255, blue: 173 / 255, alpha: 1).CGColor
    }
    
}
