//
//  QuizVideo.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/21/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation

struct QuizVideo {
    
    var questions: [Question] = [Question]()
    var asset: AVAsset!
    
    struct Question {
        
        var question: String
        var answers: [(text: String, isCorrect: Bool, number: Int)]
        var start: CMTime!
        var end: CMTime!
        
        func archive() -> [String:AnyObject] {
            var dict: [String: AnyObject] = [:]
            dict["question"] = question
            dict["start"] = Double(CMTimeGetSeconds(start))
            dict["end"] = Double(CMTimeGetSeconds(end))
            var rawanswers: [[String: AnyObject]] = []
            for answer in answers {
                var aDict: [String: AnyObject] = [:]
                aDict["text"] = answer.text
                aDict["isCorrect"] = answer.isCorrect
                aDict["number"] = answer.number
                rawanswers.append(aDict)
            }
            dict["answers"] = rawanswers
            return dict
        }
        
        init(question: String, answers: [(text: String, isCorrect: Bool, number: Int)]) {
            self.question = question
            self.answers = answers
        }
        
        init(archive: [String: AnyObject]) {
            question = archive["question"] as! String
            start = CMTimeMakeWithSeconds(archive["start"] as! Double, 10)
            end = CMTimeMakeWithSeconds(archive["end"] as! Double, 10)
            answers = [(text: String, isCorrect: Bool, number: Int)]()
            let rawanswers: [[String: AnyObject]] = archive["answers"] as! [[String:AnyObject]]
            for answer in rawanswers {
                answers.append((text: answer["text"] as! String, isCorrect: answer["isCorrect"] as! Bool, number: answer["number"] as! Int))
            }
        }
    }
    
    func archive() -> NSData {
        var dict: [String: AnyObject] = [:]
        var rawQuestions: [[String: AnyObject]] = []
        for question in questions {
            rawQuestions.append(question.archive())
        }
        dict["questions"] = rawQuestions
        
        return NSKeyedArchiver.archivedDataWithRootObject(dict)
    }
    
    init(questions: [Question], asset: AVAsset) {
        
        self.asset = asset
        self.questions = questions
    }
    
    init(archive: NSData) {
        let dict: [String : AnyObject] = NSKeyedUnarchiver.unarchiveObjectWithData(archive) as! [String: AnyObject]
        let rawQuestions: [[String: AnyObject]] = dict["questions"] as! [[String: AnyObject]]
        for question in rawQuestions {
            questions.append(Question(archive: question))
        }
    }
}

extension String {
    
    func indexOf(target: String) -> Index?
    {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.advancedBy(self.startIndex.distanceTo(range.startIndex))
        } else {
            return nil
        }
    }
}
