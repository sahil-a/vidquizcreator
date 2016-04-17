//
//  VidQuiz.swift
//  Vid Quiz Creator
//
//  Created by Sahil Ambardekar on 4/16/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa
import AVFoundation

struct VidQuiz {
    
    var questions: [Question] = [Question]()
    var composition: AVMutableComposition?
    var toneIds: [Int]?
    
    struct Question {
        var question: String
        var answers: [(text: String, isCorrect: Bool)]
        func encode() -> String {
            var dictionary: [String:String] = [String:String]()
            dictionary["q"] = question
            var count = 1
            for (text, correct) in answers {
                if correct {
                    dictionary["c"] = text
                } else {
                    dictionary["o\(count)"] = text
                    count += 1
                }
            }
            return dictionary.description
        }
    }
}
