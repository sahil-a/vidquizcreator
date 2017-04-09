//
//  QuestionView.swift
//  Quizzify
//
//  Created by Sahil Ambardekar on 4/24/16.
//  Copyright © 2016 Sahil Ambardekar. All rights reserved.
//

import Cocoa

class QuestionView: NSView, ClickButtonDelegate, NSTextFieldDelegate {

    @IBOutlet weak var questionField: NSTextField!
    @IBOutlet weak var answerOneField: NSTextField!
    @IBOutlet weak var answerTwoField: NSTextField!
    @IBOutlet weak var answerThreeField: NSTextField!
    @IBOutlet weak var answerFourField: NSTextField!
    
    @IBOutlet weak var buttonOne: ClickButton!
    @IBOutlet weak var buttonTwo: ClickButton!
    @IBOutlet weak var buttonThree: ClickButton!
    @IBOutlet weak var buttonFour: ClickButton!
    var delegate: QuestionViewDelegate?
    
    var selectedButton: ClickButton {
        get {
            let buttons = [buttonOne, buttonTwo, buttonThree, buttonFour]
            for button in buttons {
                if button.state {
                    return button
                }
            }
            return buttonOne
        }
    }
    
    @IBOutlet weak var doneButton: NSButtonCell!
    @IBOutlet weak var deleteButton: NSButtonCell!
    
    @IBOutlet weak var pinView: NSImageView!
    
    
    func clicked(sender: ClickButton) {
        let buttons = [buttonOne, buttonTwo, buttonThree, buttonFour]
        for button in buttons {
            button.state = (button == sender)
        }
    }
    
    func addInfoFromQuestion(question: QuizVideo.Question) {
        let fields = [answerOneField, answerTwoField, answerThreeField, answerFourField]
        let buttons = [buttonOne, buttonTwo, buttonThree, buttonFour]
        questionField.stringValue = question.question
        for answer in question.answers {
            fields[answer.number - 1].stringValue = answer.text
            buttons[answer.number - 1].state = answer.isCorrect
        }
        checkDone()
    }
    
    class func initFromNib() -> QuestionView
    {
        var arr: NSArray?
        NSNib(nibNamed: "QuestionView", bundle: NSBundle.mainBundle())!.instantiateWithOwner(nil, topLevelObjects: &arr)
        var view: QuestionView!
        
        for ao in arr! {
            if let v = ao as? QuestionView {
                view = v
            }
        }
        
        let fields = [view.answerOneField, view.answerTwoField, view.answerThreeField, view.answerFourField]
        for field in fields {
            field.textColor = NSColor.blackColor().colorWithAlphaComponent(0.5)
            field.placeholderString = "Option"
            field.delegate = view
        }
        view.questionField.placeholderString = "Question"
        view.questionField.textColor = NSColor.whiteColor().colorWithAlphaComponent(0.7)
        view.doneButton.enabled = false
        view.deleteButton.enabled = true
        view.questionField.delegate = view
        
        return view
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        
    }
    
    @IBAction func done(sender: AnyObject) {
        var answers: [(text: String, isCorrect: Bool, number: Int)] = [(text: String, isCorrect: Bool, number: Int)]()
        let fields = [answerOneField, answerTwoField, answerThreeField, answerFourField]

        var count = 1
        for field in fields {
         
            if field == answerOneField && selectedButton == buttonOne {
                answers.append((text: field.stringValue, isCorrect: true, number: count))
                
                
            } else if field == answerTwoField && selectedButton == buttonTwo {
                
                answers.append((text: field.stringValue, isCorrect: true, number: count))

            } else if field == answerThreeField && selectedButton == buttonThree {
                answers.append((text: field.stringValue, isCorrect: true, number: count))

                
            } else if field == answerFourField && selectedButton == buttonFour {
                
                answers.append((text: field.stringValue, isCorrect: true, number: count))

            } else {
                answers.append((text: field.stringValue, isCorrect: false, number: count))
            }
            count += 1
        }
        
        let question = QuizVideo.Question(question: questionField.stringValue, answers: answers)
        delegate?.didFinishWithQuestion(question)
    }
    
    @IBAction func delete(sender: AnyObject) {
        delegate?.didDelete()
    }
    
    func checkDone() {
        var flag = true
        let fields = [answerOneField, answerTwoField, answerThreeField, answerFourField, questionField]
        for field in fields {
            flag =  (field.stringValue == "") ? false : flag
        }
        doneButton.enabled = flag
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        checkDone()
    }
}

protocol QuestionViewDelegate {
    func didFinishWithQuestion(question: QuizVideo.Question)
    func didDelete()
}

class CenteredCell: NSTextFieldCell {
    
//    override func drawingRectForBounds(theRect: NSRect) -> NSRect {
//        let HORIZ: CGFloat = 10
//        let VERT: CGFloat = 4
//        return NSRect(x: theRect.origin.x + HORIZ, y: theRect.origin.y + VERT, width: theRect.size.width - (2 * HORIZ), height: theRect.size.height - (2 * VERT))
//    }
    
//    override func titleRectForBounds(frame: NSRect) -> NSRect {
//        let stringHeight: CGFloat = self.attributedStringValue.size().height
//        var titleRect: NSRect = super.titleRectForBounds(frame)
//        titleRect.origin.y = frame.origin.y + (frame.size.height - stringHeight) / 2.0
//        return titleRect
//    }
//    
//    override func drawInteriorWithFrame(cFrame: NSRect, inView cView: NSView) {
//        super.drawInteriorWithFrame(self.titleRectForBounds(cFrame), inView: cView)
//    }
}
