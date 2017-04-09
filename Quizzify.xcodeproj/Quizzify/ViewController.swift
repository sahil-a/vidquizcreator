//
//  ViewController.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/21/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.


import Cocoa
import AVFoundation
import MultipeerConnectivity

class ViewController: NSViewController, VolumeControlDelegate, QuestionViewDelegate, NSWindowDelegate, ConnectorDelegate, MenuViewDelegate {
    
    // UI:
    @IBOutlet weak var playerControl: PlaybarView!
    @IBOutlet weak var soundView: NSButton!
    @IBOutlet weak var playButton: NSButton!
    
    @IBOutlet weak var scrubArea: ScrubView!
    var scrubber: NSView!
    var dragging = false
    let SCRUBBER_WIDTH: CGFloat = 7.0
    var TRACK_TIME = 10.0
    
    
    // UI: Sound and Adding
    @IBOutlet weak var addButton: NSButton!
    var adjustingSound = false
    var adding = false
    var adder: QuestionView!
    private var scrubberLocation: CGFloat = 0
    var volumeControl: VolumeControl!
    var tracks: [NSView] = []
    var viewingInfo: [ViewingInfo] = []
    var selectedTrack: NSView!
    
    // Video
    var videoQuiz: QuizVideo!
    var player:AVPlayer! = AVPlayer()
    var playerLayer: AVPlayerLayer!
    @IBOutlet weak var playerView: NSView!
    var playing = false
    var seeking = false
    var shouldSelectTrack = false
    var draggingTrack = false
    var trackSelectedLoc:CGFloat!
    var selectedTrackLoc:CGFloat!
    var editing = false
    var connector = Connector()
    var locBeforeSeeking: CGFloat!
    @IBOutlet weak var menuButton: NSButton!
    var menuOpen = false
    var menuView: MenuView!
    var resultsView: ResultsView!
    var resultsOpen = false
    
    func viewResultsTapped() {
        resultsOpen = !resultsOpen
        let other = 52 * 2 - (view.frame.size.height - 52 * 2)
        resultsView.frame.origin.y =  (resultsOpen) ?  52 * 2 : other
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue =  (!resultsOpen) ?  52 * 2 : 52 * 2 - (view.frame.size.height - 52 * 2)
        animation.toValue = (resultsOpen) ?  52 * 2 : 52 * 2 - (view.frame.size.height - 52 * 2)
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        resultsView.layer?.addAnimation(animation, forKey: "o/c")
    }
    
    func windowWillClose(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        player.pause()
        player = nil
        connector.onStateChange = nil
        connector.stop()
    }
    
    func peersDidChange(peers: [Peer]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.menuView.updateWithPeers(peers)
        }
    }
    
    func peerDidRespondWith(peer: Peer, response: Response) {
        for i in 0..<viewingInfo.count {
            if videoQuiz.questions[i].question == response.question.question { // TWO QUESTIONS MUST HAVE DIFFERENT Q's
                viewingInfo[i].responses.append(response)
                resultsView.results = viewingInfo
            }
        }
    }
    
    override func viewWillAppear() {
        view.layer?.masksToBounds = false
        scrubber = NSView(frame: NSRect(origin: CGPointMake(scrubArea.frame.origin.x, scrubArea.frame.origin.y - 2.5), size: CGSizeMake(SCRUBBER_WIDTH, 37)))
        scrubber.wantsLayer = true
        scrubber.layer?.masksToBounds = false
        scrubber.layer?.cornerRadius = 2.0
        
        scrubber.layer?.backgroundColor = NSColor.whiteColor().CGColor
        view.addSubview(scrubber)
        
        volumeControl = VolumeControl(frame: NSRect(x: soundView.frame.origin.x - 1, y: playerControl.frame.height - 145, width: 41, height: 141))
        volumeControl.delegate = self
        view.addSubview(volumeControl, positioned: .Below, relativeTo: playerControl)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(windowResized), name: NSWindowDidResizeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(space), name: "space", object: nil)
        
        
        if CMTimeGetSeconds(videoQuiz.asset.duration) > 120 {
            TRACK_TIME = 20
        } else {
            TRACK_TIME = 10
        }
        loadAsset()
    }
    
    override func viewDidAppear() {
        menuView = MenuView(frame: NSRect(x: 0, y: 0, width: self.view.frame.width, height: playerControl.frame.size.height))
        view.addSubview(menuView, positioned: .Below, relativeTo: playerControl)
        menuView.delegate = self
        resultsView = ResultsView.fromNibWithFrame(NSRect(x: 0, y: 52 * 2 - (view.frame.size.height - (52 * 2)), width: view.frame.size.width, height: view.frame.size.height - (52 * 2)), viewingInfo: viewingInfo)
    }
    
    
    func space() {
        playClicked(NSButton())
    }
    
    func loadAsset() {
        playerLayer = AVPlayerLayer(player: player)
        playerView.layer!.insertSublayer(playerLayer, atIndex: 0)
        let playerItem = AVPlayerItem(asset: videoQuiz.asset)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        playerLayer?.frame = playerView.layer!.bounds
        playerLayer.autoresizingMask = [CAAutoresizingMask.LayerWidthSizable, CAAutoresizingMask.LayerHeightSizable]
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            player.currentItem?.removeObserver(self, forKeyPath: "status")
            player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.2, 100), queue: dispatch_get_main_queue(), usingBlock: { (time) in
                if !self.dragging && !self.adding && !self.seeking && !self.editing && self.player != nil {
                    let animation: CABasicAnimation = CABasicAnimation(keyPath: "position.x")
                    animation.fromValue =  self.scrubber.frame.origin.x
                    self.moveScrubberToLocation(self.CMTimeToLoc(time))
                    animation.duration = 0.2
                    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                    self.scrubber.layer!.addAnimation(animation, forKey: "playing")
                    if time == self.player.currentItem!.duration {
                        self.playing = false
                        self.playButton.image = NSImage(named: "play")
                        
                    }
                    
                }
                
                // check to see if questions need to be broadcasted
                if self.player != nil { self.broadcastWithLoc(self.CMTimeToLoc(time)) }
            })
            for question in videoQuiz.questions {
                displayQuestion(question)
            }
        }
    }
    
    func broadcastWithLoc(loc: CGFloat) {
        for i in 0..<videoQuiz.questions.count {
            
            let question = videoQuiz.questions[i]
            let info = viewingInfo[i]
            let startLoc = CMTimeToLoc(question.start)
            let allowedDistance = CMTimeToLoc(CMTimeMakeWithSeconds(3, 100))
            let distance = abs(startLoc - loc)
            if !info.hasBroadcasted && distance < allowedDistance {
                connector.sendData(NSKeyedArchiver.archivedDataWithRootObject(question.archive()))
                viewingInfo[i].hasBroadcasted = true
            } else if distance < allowedDistance && info.invalidated {
                connector.sendData(NSKeyedArchiver.archivedDataWithRootObject(question.archive()))
                viewingInfo[i].hasBroadcasted = true
                viewingInfo[i].invalidated = false
                viewingInfo[i].responses = []
            }
        }
    }
    
    
    func CMTimeToLoc(time: CMTime) -> CGFloat {
        return CGFloat(CMTimeGetSeconds(time)) / CGFloat(  CMTimeGetSeconds(self.player.currentItem!.duration))
    }
    
    func adjustedToPercentageLevel(level: Float) {
        // volume adjusted
        player.volume = level
    }
    
    func checkCanAdd() {
        var flag = true
        let distanceFromEnd = (player.currentItem!.duration - locToCMTime(scrubberLocation))
        flag = (CMTimeGetSeconds(distanceFromEnd) > TRACK_TIME) ? flag : false
        for i in 0..<tracks.count {
            let track = tracks[i]
            let question = videoQuiz.questions[i]
            let actualLoc = scrubArea.frame.size.width * scrubberLocation
            let fromEnd = CMTimeGetSeconds(locToCMTime((track.frame.origin.x - actualLoc) / scrubArea.frame.size.width))
            if (actualLoc >= (CMTimeToLoc(question.start) * scrubArea.frame.size.width) && actualLoc <= (CMTimeToLoc(question.end) * scrubArea.frame.size.width)) || (fromEnd <= TRACK_TIME && fromEnd >= 0) {
                flag = false
            }
        }
        addButton.enabled = flag
    }
    
    
    
    func windowResized() {
        volumeControl?.frame.origin.x = soundView.frame.origin.x - 1
        if let results = resultsView {
            results.frame.size = CGSizeMake(view.frame.size.width, view.frame.size.height - (52 * 2))
            let other = 52 * 2 - (view.frame.size.height - 52 * 2)
            resultsView.frame.origin.y =  (resultsOpen) ?  52 * 2 : other
        }
        if adding || editing {
            updateAdderLocation()
        }
        moveScrubberToLocation(scrubberLocation)
        for i in 0..<tracks.count {
            let track = tracks[i]
            let question = videoQuiz.questions[i]
            let start = CMTimeToLoc(question.start) * scrubArea.frame.size.width
            let end = CMTimeToLoc(question.end) * scrubArea.frame.size.width
            let width = end - start
            track.frame = NSRect(x: start, y: 0, width: width, height: scrubArea.frame.size.height / 2)
            track.subviews[0].removeFromSuperview()
            let border = NSView(frame: NSRect(x: 0, y: track.frame.size.height - 5, width: width, height: 5))
            border.wantsLayer = true
            border.layer?.backgroundColor = NSColor(colorLiteralRed: 149 / 255, green: 88 / 255, blue: 88 / 255, alpha: 1).CGColor
            track.addSubview(border)
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connector.onStateChange = { state in
            let stateString: String
            switch state {
            case .NotConnected:
                stateString = "Not Connected"
            case .Connecting:
                stateString = "Connecting..."
            case .Connected:
                stateString = "Connected"
            }
            dispatch_async(dispatch_get_main_queue()) {
                print(stateString)
            }
        }
        
        connector.delegate = self
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self.connector, selector: #selector(connector.start), userInfo: nil, repeats: false)
    }
    
    
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func addClicked(sender: NSButton) {
        if !adding && !editing {
            
            adder = QuestionView.initFromNib()
            adder.delegate = self
            if playing { playClicked(sender) }
            view.addSubview(adder)
            updateAdderLocation()
            adding = true
            sender.enabled = false
            scrubber.layer!.backgroundColor = NSColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
            
        }
    }
    
    func clickMenu() {
        menuClicked(NSButton())
    }
    
    @IBAction func menuClicked(sender: NSButton) {
    
        if resultsOpen && menuOpen {
            viewResultsTapped()
            NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(clickMenu), userInfo: nil, repeats: false)
            return
        }
        
        menuOpen = !menuOpen
        soundView.enabled = !menuOpen
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue =  (!menuOpen) ? playerControl.frame.height : 0
        animation.toValue = (menuOpen) ? playerControl.frame.height : 0
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue =  (menuOpen) ? 0 : M_PI
        rotation.toValue = (!menuOpen) ? 0 : M_PI
        rotation.duration = 0.2
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        menuButton.wantsLayer = true
        menuButton.layer?.anchorPoint = CGPointMake(0.5, 0.5)
        menuButton.layer!.addAnimation(rotation, forKey: "rotate")
        
        menuView.layer?.addAnimation(animation, forKey: "pop")
        menuView.frame.origin.y = (menuOpen) ? playerControl.frame.height : 0
        var transform = CGAffineTransformMakeRotation((!menuOpen) ? 0.0 : CGFloat(M_PI))
        transform.tx = menuButton.frame.size.width / 2
        transform.ty = menuButton.frame.size.height / 2
        menuButton.layer?.setAffineTransform(transform)
        menuView.setNeedsDisplayInRect(menuView.bounds)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(addView), userInfo: nil, repeats: false)
        if !menuOpen {
            resultsView.removeFromSuperview()

        }
    }
    
    func addView() {
        if menuOpen {
            view.addSubview(resultsView, positioned: .Below, relativeTo: menuView)
        }
    }
    
    func didDelete() {
        adder.removeFromSuperview()
        addButton.enabled = true
        scrubber.layer!.backgroundColor = NSColor.whiteColor().CGColor
        
        if adding {
            adding = false
        } else if editing {
            editing = false
            for i in 0..<tracks.count {
                if tracks[i] == selectedTrack {
                    videoQuiz.questions.removeAtIndex(i)
                    tracks.removeAtIndex(i)
                    viewingInfo.removeAtIndex(i)
                    resultsView.results = viewingInfo
                    break
                }
            }
            selectedTrack.removeFromSuperview()
            
        }
    }
    
    
    
    func didFinishWithQuestion(q: QuizVideo.Question) {
        
        var question = q
        adder.removeFromSuperview()
        addButton.enabled = true
        scrubber.layer!.backgroundColor = NSColor.whiteColor().CGColor
        if adding {
            adding = false
            // add question
            question.start = locToCMTime(scrubberLocation)
            question.end = CMTimeAdd(question.start, CMTimeMakeWithSeconds(TRACK_TIME, 100))
            videoQuiz.questions.append(question)
            displayQuestion(question)
            checkCanAdd()
        } else if editing {
            editing = false
            for i in 0..<tracks.count {
                if tracks[i] == selectedTrack {
                    let temp = videoQuiz.questions[i]
                    question.start = temp.start
                    question.end = temp.end
                    videoQuiz.questions[i] = question
                    viewingInfo[i].question = q
                }
            }
            
        }
    }
    
    func displayQuestion(question: QuizVideo.Question) {
        let start = CMTimeToLoc(question.start) * scrubArea.frame.size.width
        let end = CMTimeToLoc(question.end) * scrubArea.frame.size.width
        let width = end - start
        let track = NSView(frame: NSRect(x: start, y: 0, width: width, height: scrubArea.frame.size.height / 2))
        track.wantsLayer = true
        track.layer?.backgroundColor = NSColor(colorLiteralRed: 167 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1).CGColor
        let border = NSView(frame: NSRect(x: 0, y: track.frame.size.height - 5, width: width, height: 5))
        border.wantsLayer = true
        border.layer?.backgroundColor = NSColor(colorLiteralRed: 149 / 255, green: 88 / 255, blue: 88 / 255, alpha: 1).CGColor
        scrubArea.addSubview(track)
        track.addSubview(border)
        tracks.append(track)
        viewingInfo.append(ViewingInfo())
        viewingInfo[viewingInfo.count-1].question = question
        resultsView.results = viewingInfo
    }
    
    @IBAction func soundClicked(sender: NSButton) {
        menuButton.enabled = adjustingSound
        volumeControl?.frame.origin.x = soundView.frame.origin.x - 1
        volumeControl.frame.origin.y = (adjustingSound) ? playerControl.frame.height - 145 : playerControl.frame.height - 6
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue =  (!adjustingSound) ? playerControl.frame.height - 145 : playerControl.frame.height - 6
        animation.toValue = (adjustingSound) ? playerControl.frame.height - 145 : playerControl.frame.height - 6
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        volumeControl.layer?.addAnimation(animation, forKey: "pop")
        adjustingSound = !adjustingSound
    }
    
    @IBAction func playClicked(sender: NSButton) {
        if !adding && !editing {
            if !playing && scrubberLocation == 1 {
                moveScrubberToLocation(0)
                playing = true
                seeking = true
                                player.seekToTime(locToCMTime(0)) { (completed: Bool) -> Void in
                    self.seeking = false
                    self.player.play()
                    
                }
                playButton.image = NSImage(named: "pause")
                
            } else  {
                playing = !playing
                if playing {
                    player.play()
                    playButton.image = NSImage(named: "pause")
                } else {
                    player.pause()
                    playButton.image = NSImage(named: "play")
                }
            }
        }
    }
    
    func updateAdderLocation() {
        
        adder.frame.origin = CGPointMake(scrubber.frame.origin.x+3.5-(adder.frame.size.width/2), scrubber.frame.origin.y + scrubber.frame.height - 9)
        if adder.frame.origin.x < 0 {
            adder.frame.origin.x = 0
            let offset = (adder.frame.origin.x + adder.frame.size.width / 2) - (scrubber.frame.origin.x + scrubber.frame.size.width / 2)
            adder.pinView.frame.origin = CGPointMake(((adder.frame.origin.x + adder.frame.size.width / 2) - (adder.pinView.frame.size.width / 2)) - offset, adder.pinView.frame.origin.y)
        } else if adder.frame.origin.x > view.frame.size.width - adder.frame.size.width {
            adder.frame.origin.x = view.frame.size.width - adder.frame.size.width
            let offset = (adder.frame.origin.x + adder.frame.size.width / 2) - (scrubber.frame.origin.x + scrubber.frame.size.width / 2)
            adder.pinView.frame.origin = CGPointMake(((adder.frame.size.width / 2) - (adder.pinView.frame.size.width / 2)) - offset, adder.pinView.frame.origin.y)
        } else {
            adder.pinView.frame.origin = CGPointMake(((adder.frame.size.width / 2) - (adder.pinView.frame.size.width / 2)), adder.pinView.frame.origin.y)
        }
    }
    
    func moveScrubberToLocation(loc: CGFloat) {
        scrubber.frame.origin.x = loc * (scrubArea.frame.width - SCRUBBER_WIDTH) + 12
        if adding || editing {
            updateAdderLocation()
        }
        scrubberLocation = loc
        checkCanAdd()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if !seeking && !adding && !editing {
            let loc = theEvent.locationInWindow
            let locInScrubArea = CGPointMake(loc.x - 12, loc.y - 12)
            for track in tracks {
                if CGRectContainsPoint(track.frame, locInScrubArea) {
                    shouldSelectTrack = true
                    selectedTrack = track
                    draggingTrack = true
                    trackSelectedLoc = locInScrubArea.x
                    selectedTrackLoc = track.frame.origin.x
                }
            }
            if !shouldSelectTrack {
                if CGRectContainsPoint(scrubArea.frame, loc) {
                    moveScrubberToLocation((loc.x - 12) / (scrubArea.frame.width - SCRUBBER_WIDTH))
                    scrubberLocation = (loc.x - 12) / (scrubArea.frame.width - SCRUBBER_WIDTH)
                    dragging = true
                } else if adjustingSound {
                    soundClicked(NSButton())
                }
            }
        }
    }
    
    func locToCMTime(loc: CGFloat) -> CMTime {
        return CMTimeMakeWithSeconds(Double(CMTimeGetSeconds(player.currentItem!.duration)) * Double(loc), 100)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !seeking && !adding && !editing {
            // scrub in video
            if shouldSelectTrack {
                draggingTrack = false
                shouldSelectTrack = false
                for i in 0..<tracks.count {
                    if tracks[i] == selectedTrack {
                        let loc = theEvent.locationInWindow
                        scrubberLocation = (loc.x - 12) / (scrubArea.frame.width - SCRUBBER_WIDTH)
                        seeking = true
                        locBeforeSeeking = CGFloat(CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(player.currentItem!.duration))

                        player.seekToTime(locToCMTime(scrubberLocation)) { (completed: Bool) -> Void in
                            self.seeking = false
                            for i in 0..<self.tracks.count {
                                let trackStart = self.CMTimeToLoc(self.videoQuiz.questions[i].start)
                                if trackStart < self.scrubberLocation && trackStart > self.locBeforeSeeking {
                                    self.viewingInfo[i].invalidated = true
                                }
                            }
                        }
                        moveScrubberToLocation(scrubberLocation)
                        let question = videoQuiz.questions[i]
                        adder = QuestionView.initFromNib()
                        adder.delegate = self
                        if playing { playClicked(NSButton()) }
                        view.addSubview(adder)
                        updateAdderLocation()
                        editing = true
                        addButton.enabled = false
                        scrubber.layer!.backgroundColor = NSColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
                        adder.addInfoFromQuestion(question)
                    }
                }
            } else if draggingTrack {
                // update model
                draggingTrack = false
                for i in 0..<tracks.count {
                    if tracks[i] == selectedTrack {
                        videoQuiz.questions[i].start = locToCMTime(selectedTrack.frame.origin.x / scrubArea.frame.size.width)
                        let duration = Double(selectedTrack.frame.size.width / scrubArea.frame.width) * Double(CMTimeGetSeconds(player.currentItem!.duration))
                        videoQuiz.questions[i].end = CMTimeAdd(videoQuiz.questions[i].start, CMTimeMakeWithSeconds(duration, 100))
                    }
                }
                
            } else if theEvent.locationInWindow.y < 56 {
                dragging = false
                seeking = true
                locBeforeSeeking = CGFloat(CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(player.currentItem!.duration))

                player.seekToTime(locToCMTime(scrubberLocation)) { (completed: Bool) -> Void in
                    self.seeking = false
                    for i in 0..<self.tracks.count {
                        let trackStart = self.CMTimeToLoc(self.videoQuiz.questions[i].start)
                        if trackStart < self.locBeforeSeeking && trackStart > self.scrubberLocation {
                            self.viewingInfo[i].invalidated = true
                        }
                    }
                }
            }
        }
    }
    
    func checkValidLocForTrack(t: NSView) -> (valid: Bool, suggestedLoc: CGFloat!) {
        var loc = t.frame.origin.x / scrubArea.frame.size.width
        var duration = Double(t.frame.size.width / scrubArea.frame.width) * Double(CMTimeGetSeconds(player.currentItem!.duration))
        var distanceFromEnd = (player.currentItem!.duration - locToCMTime(loc))
        let twoSeconds = CGFloat(2 / CMTimeGetSeconds(player.currentItem!.duration)) * scrubArea.frame.size.width
        
        for i in 0..<tracks.count {
            let track = tracks[i]
            if track != t {
                let question = videoQuiz.questions[i]
                let actualLoc = scrubArea.frame.size.width * loc
                if (actualLoc + t.frame.size.width >= (CMTimeToLoc(question.start) * scrubArea.frame.size.width) && actualLoc <= (CMTimeToLoc(question.end) * scrubArea.frame.size.width)) {
                    let centerOffset = (track.frame.origin.x + track.frame.size.width / 2) - (t.frame.origin.x + track.frame.size.width)
                    if centerOffset >= 0 {
                        if track.frame.origin.x - t.frame.size.width - twoSeconds >= 0 && track.frame.origin.x - t.frame.size.width - twoSeconds < scrubArea.frame.size.width - t.frame.size.width {
                            return (valid: false, suggestedLoc: track.frame.origin.x - t.frame.size.width - twoSeconds)
                        } else {
                            return (valid: false, suggestedLoc: track.frame.origin.x + t.frame.size.width + twoSeconds)
                            
                        }
                        
                    } else {
                        if track.frame.origin.x + t.frame.size.width + twoSeconds < scrubArea.frame.size.width - t.frame.size.width && track.frame.origin.x + t.frame.size.width + twoSeconds >= 0 {
                            return (valid: false, suggestedLoc: track.frame.origin.x + t.frame.size.width + twoSeconds)
                        } else {
                            return (valid: false, suggestedLoc: track.frame.origin.x - t.frame.size.width - twoSeconds)
                            
                        }
                        
                    }
                }
            }
        }
        if CMTimeGetSeconds(distanceFromEnd) < duration {
            var sl: CGFloat = scrubArea.frame.size.width - t.frame.size.width
            t.frame.origin.x = sl
            loc = t.frame.origin.x / scrubArea.frame.size.width
            duration = Double(t.frame.size.width / scrubArea.frame.width) * Double(CMTimeGetSeconds(player.currentItem!.duration))
            distanceFromEnd = (player.currentItem!.duration - locToCMTime(loc))
            for i in 0..<tracks.count {
                let track = tracks[i]
                if track != t {
                    let question = videoQuiz.questions[i]
                    let actualLoc = scrubArea.frame.size.width * loc
                    if (actualLoc + t.frame.size.width >= (CMTimeToLoc(question.start) * scrubArea.frame.size.width) && actualLoc <= (CMTimeToLoc(question.end) * scrubArea.frame.size.width)) {
                        let centerOffset = (track.frame.origin.x + track.frame.size.width / 2) - (t.frame.origin.x + track.frame.size.width)
                        if centerOffset >= 0 {
                            if track.frame.origin.x - t.frame.size.width - twoSeconds >= 0 && track.frame.origin.x - t.frame.size.width - twoSeconds < scrubArea.frame.size.width - t.frame.size.width {
                                sl = track.frame.origin.x - t.frame.size.width - twoSeconds
                            } else {
                                sl = track.frame.origin.x + t.frame.size.width + twoSeconds
                            }
                            
                        } else {
                            if track.frame.origin.x + t.frame.size.width + twoSeconds < scrubArea.frame.size.width - t.frame.size.width && track.frame.origin.x + t.frame.size.width + twoSeconds >= 0 {
                                sl = track.frame.origin.x + t.frame.size.width + twoSeconds
                            } else {
                                sl = track.frame.origin.x - t.frame.size.width - twoSeconds
                            }
                            
                        }
                    }
                }
            }
            return (valid: false, suggestedLoc: sl)
        }
        if t.frame.origin.x < 0 {
            var sl: CGFloat = 0
            t.frame.origin.x = sl
            loc = t.frame.origin.x / scrubArea.frame.size.width
            duration = Double(t.frame.size.width / scrubArea.frame.width) * Double(CMTimeGetSeconds(player.currentItem!.duration))
            distanceFromEnd = (player.currentItem!.duration - locToCMTime(loc))
            
            for i in 0..<tracks.count {
                let track = tracks[i]
                if track != t {
                    let question = videoQuiz.questions[i]
                    let actualLoc = scrubArea.frame.size.width * loc
                    if (actualLoc + t.frame.size.width >= (CMTimeToLoc(question.start) * scrubArea.frame.size.width) && actualLoc <= (CMTimeToLoc(question.end) * scrubArea.frame.size.width)) {
                        let centerOffset = (track.frame.origin.x + track.frame.size.width / 2) - (t.frame.origin.x + track.frame.size.width)
                        if centerOffset >= 0 {
                            if track.frame.origin.x - t.frame.size.width - twoSeconds >= 0 && track.frame.origin.x - t.frame.size.width - twoSeconds < scrubArea.frame.size.width - t.frame.size.width {
                                sl = track.frame.origin.x - t.frame.size.width - twoSeconds
                            } else {
                                sl = track.frame.origin.x + t.frame.size.width + twoSeconds
                            }
                            
                        } else {
                            if track.frame.origin.x + t.frame.size.width + twoSeconds < scrubArea.frame.size.width - t.frame.size.width && track.frame.origin.x + t.frame.size.width + twoSeconds >= 0 {
                                sl = track.frame.origin.x + t.frame.size.width + twoSeconds
                            } else {
                                sl = track.frame.origin.x - t.frame.size.width - twoSeconds
                            }
                            
                        }
                    }
                }
            }
            return (valid: false, suggestedLoc: sl)
            
            
        }
        
        return (valid: true, suggestedLoc: nil)
    }
    
    
    
    override func mouseDragged(theEvent: NSEvent) {
        if !seeking && !adding && !editing {
            let loc = theEvent.locationInWindow
            
            let locInScrubArea = CGPointMake(loc.x - 12, loc.y - 12)
            if draggingTrack {
                shouldSelectTrack = false
                selectedTrack.frame.origin.x = selectedTrackLoc + (locInScrubArea.x - trackSelectedLoc)
                let (valid, suggested) = checkValidLocForTrack(selectedTrack)
                if !valid {
                    selectedTrack.frame.origin.x = suggested
                }
            } else if dragging {
                if CGRectContainsPoint(NSRect(origin: CGPointMake(scrubArea.frame.origin.x, scrubArea.frame.origin.y - 500), size: CGSizeMake(scrubArea.frame.size.width, view.frame.size.height + 2000)), loc) {
                    moveScrubberToLocation((loc.x - 12) / (scrubArea.frame.width - SCRUBBER_WIDTH))
                    scrubberLocation = (loc.x - 12) / (scrubArea.frame.width - SCRUBBER_WIDTH)
                } else {
                    if loc.x < scrubArea.frame.origin.x {
                        
                        moveScrubberToLocation(0)
                        scrubberLocation = 0
                    } else {
                        
                        moveScrubberToLocation(1)
                        scrubberLocation = 1
                    }
                }
            }
        }
    }
}




