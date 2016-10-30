//
//  Filter.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation

class Filter{
    
    static var WINDOW_SIZE = 60
    static var WINDOW_SIZE_DOUBLE = Double(WINDOW_SIZE)
    static var WINDOW_SIZE_INT32 = Int32(WINDOW_SIZE)
    
    static var window:[[Int32]] = []
    
    static var filtered:[Int32] = [0,0,0,0,0,0,0,0]
    
    static func initializeFilter(){
        for _ in 0..<8{
            window.append(DataFactory.zeros(amount: WINDOW_SIZE))
        }
    }
    
    // IMPORTANT: filter must be called after Filter is initialized!
    static func filter(emgData:[Int32]){
        for (ind, data) in emgData.enumerated(){
            let absData = abs(data)
            filtered[ind]  = filtered[ind] - window[ind].first! + absData
            window[ind] = window[ind].shiftRight(newElement: absData)
        }
    }
    
}
