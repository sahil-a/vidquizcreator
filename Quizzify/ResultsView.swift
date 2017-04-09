//
//  ResultsView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 5/1/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class ResultsView: NSView, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var titleView: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var no: NSTextField!
    
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var backButton: NSButton!
    var results: [ViewingInfo]! {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
            self.nextButton.enabled = false
            self.backButton.enabled = false
            if self.results.count > self.currentNumber {
                self.currentResults = self.results[self.currentNumber]
                self.titleView.stringValue = self.currentResults.question.question
                self.tableView.hidden = false
                self.titleView.hidden = false
                self.no.hidden = true
                if self.currentNumber < self.results.count - 1 {
                    self.nextButton.enabled = true
                }
                if self.currentNumber > 0 {
                    self.backButton.enabled = true
                }
            } else if self.results.count > 0 {
                self.currentNumber = 0
                self.currentResults = self.results[self.currentNumber]
                self.titleView.stringValue = self.currentResults.question.question
                self.tableView.hidden = false
                self.titleView.hidden = false
                self.no.hidden = true
                if self.currentNumber < self.results.count - 1 {
                    self.nextButton.enabled = true
                }
                if self.currentNumber > 0 {
                    self.backButton.enabled = true
                }
            } else {
                self.currentResults = nil
                self.titleView.stringValue = ""
                self.titleView.hidden = true
                self.no.hidden = false
            }
                self.tableView.reloadData()
            }
        }
    }
    var currentNumber: Int = 0
    var currentResults: ViewingInfo!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func updateStuff() {
        dispatch_async(dispatch_get_main_queue()) {
            self.nextButton.enabled = false
            self.backButton.enabled = false
            if self.results.count > self.currentNumber {
                self.currentResults = self.results[self.currentNumber]
                self.titleView.stringValue = self.currentResults.question.question
                self.tableView.hidden = false
                self.titleView.hidden = false
                self.no.hidden = true
                if self.currentNumber < self.results.count - 1 {
                    self.nextButton.enabled = true
                }
                if self.currentNumber > 0 {
                    self.backButton.enabled = true
                }
            } else if self.results.count > 0 {
                self.currentNumber = 0
                self.currentResults = self.results[self.currentNumber]
                self.titleView.stringValue = self.currentResults.question.question
                self.tableView.hidden = false
                self.titleView.hidden = false
                self.no.hidden = true
                if self.currentNumber < self.results.count - 1 {
                    self.nextButton.enabled = true
                }
                if self.currentNumber > 0 {
                    self.backButton.enabled = true
                }
            } else {
                self.currentResults = nil
                self.titleView.stringValue = ""
                self.titleView.hidden = true
                self.no.hidden = false
            }
            self.tableView.reloadData()
        }

    }
    
    @IBAction func back(sender: AnyObject) {
        currentNumber -= 1
        updateStuff()
    }
    
    func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(colorLiteralRed: 144 / 255, green: 164 / 255, blue: 190 / 255, alpha: 1).CGColor
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.wantsLayer = true
        tableView.layer!.backgroundColor = NSColor(colorLiteralRed: 144 / 255, green: 164 / 255, blue: 190 / 255, alpha: 1).CGColor
        tableView.enclosingScrollView?.wantsLayer = true
        tableView.enclosingScrollView?.layer?.backgroundColor = NSColor(colorLiteralRed: 144 / 255, green: 164 / 255, blue: 190 / 255, alpha: 1).CGColor
    }
    
    @IBAction func next(sender: AnyObject) {
        currentNumber += 1
        updateStuff()
    }
    
    class func fromNibWithFrame(frame: NSRect, viewingInfo: [ViewingInfo]) -> ResultsView
    {
        var arr: NSArray?
        NSNib(nibNamed: "ResultsView", bundle: NSBundle.mainBundle())!.instantiateWithOwner(nil, topLevelObjects: &arr)
        var view: ResultsView!
        
        for ao in arr! {
            if let v = ao as? ResultsView {
                view = v
            }
        }
        
        view.frame = frame
        let nib = NSNib(nibNamed: "CellView", bundle: NSBundle.mainBundle())
        view.tableView.registerNib(nib!, forIdentifier: "CellView")
        view.setup()
        view.results = viewingInfo
        view.titleView.stringValue = ""
        view.titleView.hidden = true
        view.no.hidden = false
        if viewingInfo.count > 0 {
            view.currentResults = viewingInfo[view.currentNumber]
            view.titleView.stringValue = view.currentResults.question.question
            view.tableView.hidden = false
            view.titleView.hidden = false
            view.no.hidden = true
        }
        
        return view
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("CellView", owner: self) as! CellView
        if currentResults.responses.count == 0 {
            cell.name = "No responses recorded"
            cell.answer = ""
            if let _ = cell.imageView.superview {
                cell.imageView.hidden = true
            }
            return cell
        } else {
        cell.imageView.hidden = false
        let response = currentResults.responses[row]
        cell.name = response.responder
        let question = response.question
        var answer: String!
        var correct: Bool = false
        for a in question.answers {
            if a.number == response.choice {
                answer = a.text
                correct = a.isCorrect
            }
        }
        cell.answer = answer
        cell.correct = correct
        return cell
        }
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 63
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let c = currentResults {
            if c.responses.count == 0 {
                return 1
            }
            return c.responses.count
        }
        return 0
    }
}
