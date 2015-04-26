//
//  GraphingModel.swift
//  Calculator
//
//  Created by Dan Li on 4/25/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import Foundation

class GraphingModel: CalculatorBrain {
    
     func evaluate(variableName: String, variableValue: Double) -> Double? {
        let readProgram = program as? [String]
        variableValues[variableName] = variableValue
        let result = super.evaluate()
        return result
    }
}