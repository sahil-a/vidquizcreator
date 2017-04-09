//
//  Document.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/21/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation



class Document: NSDocument, NSWindowDelegate {
    
    var exporter: AVAssetExportSession!
    weak var windowController: NSWindowController!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        windowController.window?.delegate = (windowController.contentViewController as? Mediator)?.childViewControllers[0] as? ViewController
        windowController.shouldCloseDocument = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(switched), name: "switched", object: nil)
        
        addWindowController(windowController)
    }
    
    func switched() {
        windowController.window?.delegate = (windowController.contentViewController as? Mediator)?.childViewControllers[0] as? ViewController
    }
    
    override func writeToURL(url: NSURL, ofType typeName: String) throws {
        var name = url.pathComponents![url.pathComponents!.count - 1]
        name = name.substringToIndex(name.indexOf(".qv")!)
        let mediator = self.windowControllers[0].contentViewController as! Mediator
        mediator.name = name
        let fileManager = NSFileManager()
        do {
            try fileManager.createDirectoryAtURL(url.URLByAppendingPathComponent("contents", isDirectory: false), withIntermediateDirectories: true, attributes: nil)
            let contents = url.URLByAppendingPathComponent("contents", isDirectory: true)
            if let vc = windowControllers[0].contentViewController?.childViewControllers[0] as? ViewController {
                let videoQuiz = vc.videoQuiz
                videoQuiz.archive().writeToURL(contents.URLByAppendingPathComponent("videoData"), atomically: true)
                exporter = AVAssetExportSession(asset: videoQuiz.asset, presetName: AVAssetExportPresetHighestQuality)
                exporter.outputFileType = AVFileTypeMPEG4
                exporter.outputURL = contents.URLByAppendingPathComponent("video.mp4", isDirectory: false)
                let mediator = windowControllers[0].contentViewController as! Mediator
                let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(updateSaveProgress), userInfo: nil, repeats: true)
                mediator.presentViewControllerAsSheet(mediator.progressVC)
                exporter.exportAsynchronouslyWithCompletionHandler({
                    dispatch_async(dispatch_get_main_queue()) {
                        mediator.dismissViewController(mediator.progressVC)
                        timer.invalidate()
                        for view in mediator.progressVC.view.subviews {
                            if let progressIndicator = view as? NSProgressIndicator {
                                progressIndicator.doubleValue = 0
                            }
                        }
                    }
                })
            }
            
        } catch {
            print("Error saving directory")
        }

    }
    override func writeSafelyToURL(url: NSURL, ofType typeName: String, forSaveOperation saveOperation: NSSaveOperationType) throws {
        var name = url.pathComponents![url.pathComponents!.count - 1]
        name = name.substringToIndex(name.indexOf(".qv")!)
        let mediator = self.windowControllers[0].contentViewController as! Mediator
        mediator.name = name
        if saveOperation == NSSaveOperationType.AutosaveInPlaceOperation {
        let fileManager = NSFileManager()
        do {
            try fileManager.createDirectoryAtURL(url.URLByAppendingPathComponent("contents", isDirectory: false), withIntermediateDirectories: true, attributes: nil)
            let contents = url.URLByAppendingPathComponent("contents", isDirectory: true)
            if let vc = windowControllers[0].contentViewController?.childViewControllers[0] as? ViewController {
                let videoQuiz = vc.videoQuiz
                videoQuiz.archive().writeToURL(contents.URLByAppendingPathComponent("videoData"), atomically: true)
                exporter = AVAssetExportSession(asset: videoQuiz.asset, presetName: AVAssetExportPresetHighestQuality)
                exporter.outputFileType = AVFileTypeMPEG4
                exporter.outputURL = contents.URLByAppendingPathComponent("video.mp4", isDirectory: false)
                exporter.exportAsynchronouslyWithCompletionHandler({
                    dispatch_async(dispatch_get_main_queue()) {
                    }
                })
            }
            
        } catch {
            print("Error saving directory")
        }
        } else {
            let fileManager = NSFileManager()
            do {
                try fileManager.createDirectoryAtURL(url.URLByAppendingPathComponent("contents", isDirectory: false), withIntermediateDirectories: true, attributes: nil)
                let contents = url.URLByAppendingPathComponent("contents", isDirectory: true)
                if let vc = windowControllers[0].contentViewController?.childViewControllers[0] as? ViewController {
                    let videoQuiz = vc.videoQuiz
                    videoQuiz.archive().writeToURL(contents.URLByAppendingPathComponent("videoData"), atomically: true)
                    exporter = AVAssetExportSession(asset: videoQuiz.asset, presetName: AVAssetExportPresetHighestQuality)
                    exporter.outputFileType = AVFileTypeMPEG4
                    exporter.outputURL = contents.URLByAppendingPathComponent("video.mp4", isDirectory: false)
                    let mediator = windowControllers[0].contentViewController as! Mediator
                    let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(updateSaveProgress), userInfo: nil, repeats: true)
                    mediator.presentViewControllerAsSheet(mediator.progressVC)
                    exporter.exportAsynchronouslyWithCompletionHandler({
                        dispatch_async(dispatch_get_main_queue()) {
                            mediator.dismissViewController(mediator.progressVC)
                            timer.invalidate()
                            for view in mediator.progressVC.view.subviews {
                                if let progressIndicator = view as? NSProgressIndicator {
                                    progressIndicator.doubleValue = 0
                                }
                            }
                        }
                    })
                }
                
            } catch {
                print("Error saving directory")
            }
        }

    }
    
    func updateSaveProgress() {
        let mediator = windowControllers[0].contentViewController as! Mediator
        for view in mediator.progressVC.view.subviews {
            if let progressIndicator = view as? NSProgressIndicator {
                progressIndicator.doubleValue = Double(exporter.progress)
            }
        }
    }
    
    override func readFromURL(url: NSURL, ofType typeName: String) throws {
        let contents = url.URLByAppendingPathComponent("contents", isDirectory: true)
        let videoDataURL = contents.URLByAppendingPathComponent("videoData", isDirectory: false)
        let vd = NSData(contentsOfURL: videoDataURL)
        guard let videoData = vd else {
            
            return
        }
        var videoQuiz = QuizVideo(archive: videoData)
        let asset: AVAsset = AVURLAsset(URL: contents.URLByAppendingPathComponent("video.mp4", isDirectory: false))
        asset.loadValuesAsynchronouslyForKeys(["tracks"]) { 
            videoQuiz.asset = asset
            dispatch_async(dispatch_get_main_queue()) {
                if self.windowControllers.count == 0 {
                    self.makeWindowControllers()
                }
                var name = url.pathComponents![url.pathComponents!.count - 1]
                name = name.substringToIndex(name.indexOf(".qv")!)
                let mediator = self.windowControllers[0].contentViewController as! Mediator
                mediator.name = name
                mediator.loadFromVideoQuiz(videoQuiz)
                self.windowController.window?.delegate = (self.windowController.contentViewController as? Mediator)?.childViewControllers[0] as? ViewController
            }
        }
    }
    
    
}

