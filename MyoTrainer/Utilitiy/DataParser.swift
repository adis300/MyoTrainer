//
//  DataParser.swift
//  MyoTrainer
//
//  Created by Disi A on 12/1/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation
import SwiftLearn

class DataParser{
    static func parseCSV(path: String, inputCols: CountableRange<Int>, outputCol: Int, skipHeader:Bool = false) -> [LabeledData]{
        
        var labeledData:[LabeledData] = []
        
        if let streamReader = StreamReader(path: path) {
            var currentRow = 0
            defer {
                streamReader.close()
            }
            while let line = streamReader.nextLine() {
                let data = line.components(separatedBy: ",")
                let inputs = data[inputCols].map{ Double($0)! }
                let output = Int(data[outputCol])!
                labeledData.append(LabeledData(input: inputs, label: output, labelSize: 4))
            }
            
        }else{
            print("ERROR: Cannot read data file, empty path")
        }
        
        return labeledData
    }
}
