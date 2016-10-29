//
//  Activation.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation

class Activation{
    
    static let SIMPLE_ACTIVATION_THRESHOLD = 80
    
    static func activateSimple(emgData:[Int8]) -> Bool{
        
        let absData = emgData.reduce(0, {$0 + abs(Int($1))})
        
        return absData > SIMPLE_ACTIVATION_THRESHOLD
    }
}
