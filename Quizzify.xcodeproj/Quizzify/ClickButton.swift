//
//  ClickButton.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/24/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

@IBDesignable class ClickButton: NSView {
    
    @IBOutlet var delegate: AnyObject?
    private var innerDisplay: NSView!
    
    @IBInspectable var state: Bool = false {
        didSet {
            innerDisplay.hidden = !state
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        innerDisplay = NSView(frame: NSRect(x: 4, y: 4, width: frame.size.width - 8, height: frame.size.height - 8))
        innerDisplay.wantsLayer = true
        innerDisplay.layer!.backgroundColor = NSColor(colorLiteralRed: 96 / 255, green: 129 / 255, blue: 172 / 255, alpha: 1).CGColor
        innerDisplay.layer?.cornerRadius = 1.0
        addSubview(innerDisplay)
        innerDisplay.hidden = !state
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerDisplay = NSView(frame: NSRect(x: 4, y: 4, width: frame.size.width - 8, height: frame.size.height - 8))
        innerDisplay.wantsLayer = true
        innerDisplay.layer!.backgroundColor = NSColor(colorLiteralRed: 96 / 255, green: 129 / 255, blue: 172 / 255, alpha: 1).CGColor
        innerDisplay.layer?.cornerRadius = 1.0
        addSubview(innerDisplay)
        innerDisplay.hidden = !state
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor(colorLiteralRed: 170 / 255, green: 188 / 255, blue: 212 / 255, alpha: 1).CGColor
        self.layer!.cornerRadius = 3.7
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let del = delegate as? ClickButtonDelegate {
            del.clicked(self)
        }
    }
    
}

protocol ClickButtonDelegate {
    func clicked(sender: ClickButton)
}


