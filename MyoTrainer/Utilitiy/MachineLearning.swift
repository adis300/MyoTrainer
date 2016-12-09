//
//  MachineLearning.swift
//  MyoTrainer
//
//  Created by Disi A on 12/8/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Foundation
import SwiftLearn

var network: Network = Network([16,12,4])
var networkTrained = false

class MachineLearning{
    static func train(path: String){
        let labeledData = DataParser.parseCSV(path: path, inputCols:  0..<16, outputCol: 16).shuffled()
        let separationIndex = (labeledData.count * 5 / 6)
        let trainingSet = Array(labeledData[0..<separationIndex])
        let testSet = Array(labeledData[separationIndex..<labeledData.count])
        // Redo training
        if networkTrained {
            network = Network([16,12,4])
        }
        
        network.SGD(trainingSet: trainingSet, epochs: 100, miniBatchSize: 100, eta: 4, testSet: testSet)
        
        networkTrained = true
        
        print("Biases:")
        print(network.biases)
        print("Weights:")
        print(network.weights)
        
    }
    
    static func saveNetwork(path:String) -> Bool{
        if networkTrained{
            do{
                try network.toJson().write(to: URL(fileURLWithPath: path))
                print("Network saved successfully")
                return true
            }catch{
                print("Network failed to save")
                print(error.localizedDescription)
            }

        }else{
            print("Network is not yet trained")
        }
        return false
    }
    
    static func loadNetwork(path:String) -> Bool {
        do{
            let jsonData = try Data(contentsOf:  URL(fileURLWithPath: path))
            
            network = Network(jsonData: jsonData)
            print("Network loaded successfully")
            return true
        }catch{
            print("Network failed to load")
            print(error.localizedDescription)
        }
        return false
    }
}
