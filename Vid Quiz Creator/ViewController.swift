//
//  ViewController.swift
//  Vid Quiz Creator
//
//  Created by Sahil Ambardekar on 4/16/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation
import Alamofire
import SSZipArchive

class ViewController: NSViewController, DropViewDelegate, ControlViewDelegate {
    
    let lisnr_api_key = "90d3a3e2-7f10-4e35-90eb-f3790626e094"
    let lisnr_api_url = "https://api.lisnr.com/api/v1/"
    
    @IBOutlet weak var finishButton: NSButton!
    
    var document: NSDocument!
    @IBOutlet weak var dropView: DropView!
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var vidquiz: VidQuiz = VidQuiz()
    @IBOutlet weak var playerView: NSView!
    @IBOutlet weak var control: ControlView!
    var seeking = false
    var pendingLocs:[CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        document = NSDocumentController.sharedDocumentController().documents[0] as! Document
        dropView.hidden = false
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            
        }
    }
    
    func foundAsset(asset: AVAsset) {
        finishButton.hidden = false
        dropView.hidden = true
        playerView.hidden = false
        control.hidden = false
        playerLayer = AVPlayerLayer(player: player)
        playerView.layer!.insertSublayer(playerLayer, atIndex: 0)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        playerLayer?.frame = playerView.layer!.bounds
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: nil)
        self.vidquiz.composition = AVMutableComposition()
        let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        
        do {
            
            try self.vidquiz.composition?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration), ofAsset: asset, atTime: kCMTimeZero)

        } catch {
            
            print("error creating comp")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            player.currentItem?.removeObserver(self, forKeyPath: "status")
            playerLayer.frame.size = playerLayer.videoRect.size
            playerLayer.frame.origin = CGPointZero
            
            view.frame.size = CGSizeMake(playerLayer.videoRect.size.width - 3, playerLayer.videoRect.size.height + control.frame.height)
            view.window?.setFrame(CGRect(origin: view.window!.frame.origin, size: view.frame.size), display: true)
            player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.1, 10), queue: dispatch_get_main_queue(), usingBlock: { (time) in
                if !self.control.dragging && !self.seeking && !self.control.adding {
                    self.control.moveScrubberToLocation(CGFloat(CMTimeGetSeconds(time)) / CGFloat(CMTimeGetSeconds(self.player.currentItem!.duration)))
                }
            })
        }
    }

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
    
        playerLayer?.frame = playerView.layer!.bounds
    }
    
    
    @IBAction func finish(sender: NSButton) {
        
        sender.hidden = true
        let playerItem = AVPlayerItem(asset: vidquiz.composition!)
        player.replaceCurrentItemWithPlayerItem(playerItem)
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: nil)

        
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
    
    func scrubToLocation(loc: CGFloat) {
        seeking = true
        player.seekToTime(CMTimeMakeWithSeconds(Double(CMTimeGetSeconds(player.currentItem!.duration)) * Double(loc), 10)) { (completed: Bool) -> Void in
            self.seeking = false
        }
    }
    
    func findURLForAudioTag(audioTag: Int) {
            Alamofire.request(.GET, "\(lisnr_api_url)audio-tags/", headers: ["Authorization":"apikey \(lisnr_api_key)"]) .responseJSON { response in
                if let res = response.result.value as? [String: AnyObject] {
                    
                    if let data = res["data"] as? [String:AnyObject] {
                        if let audioTags = data["audioTags"] as? [[String:AnyObject]] {
                            for tag in audioTags {
                                if let id = tag["id"] as? Int {
                                    
                                    if id == audioTag {
                                        
                                        if let files = tag["files"] as? [[String:String]] {
                                            let url = files[0]["url"]
                                            if url == "" {
                                                dispatch_async(dispatch_get_main_queue()) {
                                                    self.findURLForAudioTag(audioTag)
                                                }
                                            } else {
                                                
                                                // download audio
                                                var fn = ""
                                                
                                                var localPath: NSURL?
                                                Alamofire.download(.GET,
                                                    url!,
                                                    destination: { (temporaryURL, response) in
                                                        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
                                                        let pathComponent = response.suggestedFilename
                                                        print(pathComponent)
                                                        fn = pathComponent!
                                                        localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                                                        return localPath!
                                                        
                                                })
                                                    .response { (request, response, _, error) in
                                                        print("Downloaded file to \(localPath!)")
                                                        let to = (localPath?.path!.substringToIndex(localPath!.path!.startIndex.advancedBy(localPath!.path!.characters.count - 4)))!
                                                        SSZipArchive.unzipFileAtPath(localPath?.path!, toDestination: to, progressHandler: nil, completionHandler: { (string, bool, error) in
                                                            
                                                            let asset = AVURLAsset(URL: NSURL(string: "file://" + to + "/" + fn.substringToIndex(fn.startIndex.advancedBy(fn.characters.count - 4)) + ".wav")!)
                                                            
                                                            let loc = self.pendingLocs.removeFirst()
                                                            dispatch_async(dispatch_get_main_queue()) {
                                                                
                                                                self.insertAssetAtLocation(asset, location: loc)
                                                            }
                                                        })
                                                }
                                            }
                                        }
                                    }
                                }
                               
                            }
                        }
                    }
                }
            }
    }
    
    func insertAssetAtLocation(asset: AVAsset, location: CGFloat) {
        
        asset.loadValuesAsynchronouslyForKeys(["tracks"]) {
            let audioTrack = asset.tracksWithMediaType(AVMediaTypeAudio)[0]

            
            do {
                
                try self.vidquiz.composition?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration), ofAsset: asset, atTime: CMTimeMakeWithSeconds(Double(CMTimeGetSeconds(self.player.currentItem!.duration)) * Double(location), 10))
                
            } catch {
                
                print("error adding audio clip!!")
            }
        }
    }
    
    func exportComposition() {
        
        
    }
    
    func addedQuestion(loc: CGFloat, question: VidQuiz.Question) {
        
        vidquiz.questions.append(question)
        
        let parametersOne = [
            "defaultFile": [
                "frequency":48000,
                "amplitude":0.2,
                "length":10
            ]
        ]
        
        Alamofire.request(.POST, "\(lisnr_api_url)audio-tags/", parameters: parametersOne , encoding: .JSON, headers: ["Authorization":"apikey \(lisnr_api_key)"]) .responseJSON { response in
            
            if let val = response.result.value as? [String:AnyObject] {
                if let data = val["data"] as? [String:AnyObject] {
                    if let audioTags = data["audioTags"] as? [[String:AnyObject]] {
                        if let id = audioTags[0]["id"] as? Int {
                            let parametersTwo: [String:AnyObject] = [
                                "type":"notification",
                                "title":"Vid Quiz",
                                "notificationText":question.encode(),
                                "audioTag":id
                            ]
                            
                            Alamofire.request(.POST, "\(self.lisnr_api_url)contents/", parameters: parametersTwo , encoding: .JSON, headers: ["Authorization":"apikey \(self.lisnr_api_key)"])
                            self.findURLForAudioTag(id)
                            self.pendingLocs.append(loc)

                        }
                    }
                }
            }
        }
        
    }
}

