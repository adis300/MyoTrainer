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
    
    static func activateSimple(emgData:[Int32]) -> Bool{
        
        let absData = emgData.reduce(0, {$0 + abs($1)})
        
        return absData > SIMPLE_ACTIVATION_THRESHOLD
    }
}
