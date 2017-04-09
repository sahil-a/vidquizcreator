//
//  Mediator.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/24/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class Mediator: NSViewController {

    @IBOutlet weak var container: NSView!
    lazy var progressVC: NSViewController = {
        return self.storyboard!.instantiateControllerWithIdentifier("sheetController")
            as! NSViewController
    }()
    
    var name: String = "Untitled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func picked() {
        let asset = (childViewControllers[0] as! DropViewController).asset
        childViewControllers[0].removeFromParentViewController()
        for subview in container.subviews {
            subview.removeFromSuperview()
        }
        let dvc = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("videoPlayer") as! ViewController
        while dvc.videoQuiz == nil {
            dvc.videoQuiz = QuizVideo(questions: [], asset: asset)
        }
        let dv = dvc.view
        container.addSubview(dv)
        dv.frame.size = container.frame.size
        addChildViewController(dvc)
        dv.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        NSNotificationCenter.defaultCenter().postNotificationName("switched", object: nil)
        dvc.connector.name = name
    }
    
    func loadFromVideoQuiz(quiz: QuizVideo) {
        childViewControllers[0].removeFromParentViewController()
        for subview in container.subviews {
            subview.removeFromSuperview()
        }
        let dvc = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("videoPlayer") as! ViewController
        dvc.videoQuiz = quiz
        let dv = dvc.view
        container.addSubview(dv)
        dv.frame.size = container.frame.size
        addChildViewController(dvc)
        dv.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        dvc.connector.name = name
    }
}
