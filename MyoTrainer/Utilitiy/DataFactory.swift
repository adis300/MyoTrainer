//
//  DataFactory.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation

class DataFactory{
    
    // static var LINE_CHART_DEFAULT_DATA: [Int8] = Array(0...100).map{x in return 0}

    static var LINE_CHART_DEFAULT_DATA: [[Int8]] {
        let entryArr:[Int8] = Array(0...100).map{x in return 0}
        return Array(0...8).map{x in return entryArr.map { $0}}
    }
    
    func zeros(amount:Int) -> [Int]{
        return (0...amount).map{x in return 0}
    }
    
    
}
