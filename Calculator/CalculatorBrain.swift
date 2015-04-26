//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Dan Li  on 4/10/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import Foundation

class CalculatorBrain: Printable {
    
    enum Op: Printable {
        case Operand(Double)
        case Constant(String, Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case Op.Operand(let operand):
                    return "\(operand)"
                case Op.Constant(let symbol,_):
                    return "\(symbol)"
                case Op.Variable(let symbol):
                    return "\(symbol)"
                case Op.UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case Op.BinaryOperation(let symbol,_):
                    return "\(symbol)"
                }
            }
        }
    }
    
    var description: String {
        get {
            return getDescriptionFromStack(opStack)
        }
    }
    
    private func getDescriptionFromStack(stack: [Op]) -> String {
        var stackString = [String]()
        for i in 0..<stack.count {
            let op = stack[i]
            switch op {
            case Op.UnaryOperation(let symbol, _):
                if (stack.count > 1) {
                    var newExpression = "\(symbol)\(stackString[stackString.endIndex-1])"
                    var parenthesisInsertionIndex = advance(newExpression.startIndex, count(symbol))
                    if !stackString[stackString.endIndex-1].hasSuffix(")") {
                        newExpression.insert("(", atIndex: parenthesisInsertionIndex)
                        newExpression.insert(")", atIndex: newExpression.endIndex)
                    }
                    stackString.removeAtIndex(stackString.endIndex-1)
                    stackString.append(newExpression)
                }
                else {
                    stackString = ["\(symbol)(?)"]
                }
            case Op.BinaryOperation(let symbol, _):
                if (stackString.count >= 2 && stackString[stackString.endIndex-3] != ", " && stackString[stackString.endIndex-1] != ", ") {
                    stackString.removeAtIndex(stackString.endIndex-2)
                    let newExpression = "(\(stackString[stackString.endIndex-2])\(symbol)\(stackString[stackString.endIndex-1]))"
                    stackString.removeAtIndex(stackString.endIndex-1)
                    stackString.removeAtIndex(stackString.endIndex-1)
                    stackString.append(newExpression)
                }
                else if (stackString.count == 1 && stackString[stackString.endIndex-1] != ", ") {
                    let newExpression = "(?\(symbol)\(stackString[stackString.endIndex-1]))"
                    stackString.removeAtIndex(stackString.endIndex-1)
                    stackString.append(newExpression)
                }
                else {
                    stackString.append("?\(symbol)?")
                }
            default:
                if(stackString.count > 0) {
                    stackString.append(", ")
                }
                stackString.append(op.description)
            }
        }
        stackString.append(" =")
        return String().join(stackString)
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.Constant("π", M_PI))
        
    }
    
    var program: AnyObject { // guarenteed to be a PropertyList
        get {
            return opStack.map({$0.description})
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(Op.Operand(operand))
                    }
                    else {
                        newOpStack.append(Op.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case Op.Operand(let operand):
                return (operand, remainingOps)
            case Op.Constant(_, let value):
                return (value, remainingOps)
            case Op.Variable(let name):
                return (variableValues[name], remainingOps)
            case Op.UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case Op.BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        //println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func saveVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clearStack() {
        opStack = [Op]()
    }
    
    func clearVariables() {
        variableValues = [String:Double]()
    }
    
}