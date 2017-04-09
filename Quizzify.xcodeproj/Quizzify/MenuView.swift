//
//  MenuView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/30/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

protocol MenuViewDelegate {
    func viewResultsTapped()
}

class MenuView: NSView {
    
    var button: NSView!
    var label: NSTextView!
    var scrollView: NSScrollView!
    var contentView: NSView!
    private var peerCount = 0
    var delegate: MenuViewDelegate?
    private var clicked = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    func setupView() {
        button = NSView(frame: NSRect(x: frame.size.width - 112, y: 0, width: 112, height: frame.size.height))
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor(colorLiteralRed: 167 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1).CGColor
        button.layer?.shadowColor = NSColor.blackColor().CGColor
        button.layer?.shadowOpacity = 0.3
        button.layer?.shadowRadius = 3
        button.layer?.shadowOffset = CGSizeMake(-4, 0)
        button.layer?.shouldRasterize = true
        button.layer?.masksToBounds = false
        self.wantsLayer = true
        layer?.backgroundColor = NSColor(colorLiteralRed: 167 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1).CGColor
        self.layer?.shadowColor = NSColor.blackColor().CGColor
        self.layer?.shadowOpacity = 0.25
        self.layer?.shadowRadius = 4
        self.layer?.shadowOffset = CGSizeMake(0, 3)
        self.layer?.masksToBounds = false
        self.layer?.shouldRasterize = true
        self.autoresizingMask = [.ViewWidthSizable]
        label = NSTextView(frame: self.frame)
        label.string = "View Results"
        label.textColor = NSColor.whiteColor()
        label.alignment = .Center
        label.font = NSFont.systemFontOfSize(13.6, weight: NSFontWeightMedium)
        label.frame = button.frame
        label.frame.origin.y = -20
        label.backgroundColor = NSColor.clearColor()
        addSubview(button)
        addSubview(label)
        label.selectable = false
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: frame.width - 112, height: frame.height))
        scrollView.hasHorizontalScroller = true
        contentView = NSView(frame: NSRect(x: 0, y: 0, width: 29, height: frame.height))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clearColor().CGColor
        scrollView.wantsLayer = true
        scrollView.drawsBackground = false
        scrollView.documentView = contentView
        addSubview(scrollView)
    }
    
    func updateWithPeers(peers: [Peer]) {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        contentView.frame.size.width = 29
        peerCount = 0
        for peer in peers {
            let pv = ProfileView(peer: peer, frame: CGRectMake(CGFloat(13 + (39 * peerCount)), (frame.height - 29) / 2, 29, 29))
            contentView.frame.size.width += 39
            contentView.addSubview(pv)
            peerCount += 1
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()

    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        button.frame.origin.x = frame.size.width - 112
        button.layer?.shadowColor = NSColor.blackColor().CGColor
        button.layer?.shadowOpacity = 0.3
        button.layer?.shadowRadius = 3
        button.layer?.shadowOffset = CGSizeMake(-4, 0)
        button.layer?.shouldRasterize = true
        button.layer?.masksToBounds = false
        label.frame = button.frame
        label.frame.origin.y = -20
        scrollView.frame = NSRect(x: 0, y: 0, width: frame.width - 112, height: frame.height)
        self.layer?.shadowColor = NSColor.blackColor().CGColor
        self.layer?.shadowOpacity = 0.25
        self.layer?.shadowRadius = 4
        self.layer?.shadowOffset = CGSizeMake(0, 3)
        self.layer?.masksToBounds = false
        self.layer?.shouldRasterize = true
        let clickRecognizer = NSPressGestureRecognizer(target: self, action: #selector(clickedButton))
        clickRecognizer.minimumPressDuration = 0
        button.addGestureRecognizer(clickRecognizer)
        label.addGestureRecognizer(clickRecognizer)
        
    }
    
    func clickedButton(recognizer: NSPressGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            label.textColor = NSColor.whiteColor().colorWithAlphaComponent(0.2)
        case .Ended:
            label.textColor = NSColor.whiteColor()
            delegate?.viewResultsTapped()
        default:
            break
        }
    }
    
}

class ProfileView: NSView {
    
    var color: NSColor
    var title: String
    private var titleLabel: NSTextView!
    
    
    init(peer: Peer, frame: CGRect) {
        color = peer.color
        title = peer.letter
        super.init(frame: frame)
        titleLabel = NSTextView(frame: CGRectMake(0, -8.5, frame.size.width, frame.size.height))
        titleLabel.string = title
        titleLabel.font = NSFont.systemFontOfSize(11.6, weight: NSFontWeightBold)
        titleLabel.textColor = NSColor(colorLiteralRed: 0.267, green: 0.267, blue: 0.267, alpha: 1)
        titleLabel.alignment = .Center
        titleLabel.drawsBackground = false
        titleLabel.selectable = false
        addSubview(titleLabel)
        
    }
    
    required init?(coder: NSCoder) {
        color = NSColor.whiteColor()
        title = "?"
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        self.layer?.backgroundColor = color.CGColor
        self.layer?.cornerRadius = frame.size.width / 2
    }
}
