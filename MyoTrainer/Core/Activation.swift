//
//  Activation.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation

class Activation{
    
    static let SIMPLE_ACTIVATION_THRESHOLD: Int32 = 80
    
    static let ACITVATION_WEIGHTS:[Double] = [5,7,7,2,1,1,2,5].map{$0/30}
    // Defines the filtered center for each
    static let ACITVATION_CENTERS:[Double] = [6,5,3,5,3,3,3,3].map{$0 * Filter.WINDOW_SIZE_DOUBLE}
    
    static let ACITVATION_STEEPNESS:[Double] = [3,3,3,3,1,1,1,3]

    static let NN_1L_THRESHOLD = 0.5 // *1
    
    static func activateSimple(emgData:[Int32]) -> Bool{
        
        let absData = emgData.reduce(0, {$0 + abs($1)})
        
        return absData > SIMPLE_ACTIVATION_THRESHOLD
    }
    
    static func logisticStepForFilteredEmg(filteredEmg: [Int32]) -> Bool{
        // 1 / (1 + exp(-a(x-b/a))) * ActivationWeight
        let activationSignal = filteredEmg.enumerated().map{ x, y -> Double in
            
            // print(Double(y) - ACITVATION_CENTERS[x])
            // print(exp(ACITVATION_STEEPNESS[x] * (ACITVATION_CENTERS[x] - Double(y))))
            return ACITVATION_WEIGHTS[x] / (1 + exp(ACITVATION_STEEPNESS[x] * (ACITVATION_CENTERS[x] - Double(y))))
            // print("Result")
            // print(val)
            // return val
        }
        return activationSignal.reduce(0, +) > NN_1L_THRESHOLD
    }
}
