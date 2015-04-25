//
//  ViewController.swift
//  Calculator
//
//  Created by Dan Li  on 4/7/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var stackDisplay: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if let newDisplay = NSNumberFormatter().numberFromString(display.text! + digit){
                display.text = display.text! + digit
            }
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
        updateStackDisplay()
    }
    
    func updateStackDisplay() {
        stackDisplay.text = brain.description
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let displayValueToEval = displayValue {
            var result = brain.pushOperand(displayValueToEval)
            displayValue = result
        }
        updateStackDisplay()
     }
    
    @IBAction func clearDisplay() {
        userIsInTheMiddleOfTypingANumber = false
        display.text = "0"
        brain.clearStack()
        brain.clearVariables()
        stackDisplay.text = " ="
    }
    
    @IBAction func saveM() {
        userIsInTheMiddleOfTypingANumber = false
        if let unwrappedDisplayValue = displayValue {
            if let result = brain.saveVariable("M", value: unwrappedDisplayValue) {
                displayValue = result
            }
        }
        updateStackDisplay()
    }
    
    @IBAction func retrieveM() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayValue = brain.pushOperand("M")
        updateStackDisplay()
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if let newDisplayValue = newValue {
                display.text = "\(newDisplayValue)"
            }
            else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

