//
//  Filter.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation

class Filter{
    
    static var WINDOW_SIZE = 10
    
    static var window:[[Int32]] = []
    
    static var filtered:[Int32] = [0,0,0,0,0,0,0,0]
    
    static func initializeFilter(){
        for _ in 0..<8{
            window.append(DataFactory.zeros(amount: 10))
        }
    }
    
    
    
}
