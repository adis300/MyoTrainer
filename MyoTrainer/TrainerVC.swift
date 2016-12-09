//
//  TrainerVC.swift
//  MyoTrainer
//
//  Created by Disi A on 11/27/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa
import Charts
import SwiftLearn

class TrainerVC: NSViewController, MyoDelegate {
    
    @IBOutlet weak var barChart: BarChartView!
    let skipper = 30
    var skipperCounter = 0
    var testSkipper = 10
    var testSkipperCounter = 0

    var myo:Myo?
    var fileOutputStream:OutputStream?
    
    @IBOutlet weak var trainingStatusLabel: NSTextField!

    var activated = false
    var waiting = false
    static var isTestingNetwork = false
    
    var trainingLabelCount = [0,0,0,0]// Fist, stretch, point, click
    

    static var gestureLabelNames = ["Fist","Stretch","Point","Click"]
    var trainingLabelNames = gestureLabelNames.map{"Please make gesture:" + $0}
    
    var trainingDataSize = 3000
    
    @IBOutlet weak var trainingCountLabel: NSTextField!
    
    var currentTrainingLabel = 0 // Fist
    
    @IBOutlet weak var activationIndicator: ActivationIndicator!
    
    @IBOutlet weak var trainingInstruction: NSTextField!
    @IBOutlet weak var myoStatusLabel: NSTextField!

    @IBOutlet weak var startRecordingButton: NSButton!

    @IBOutlet weak var dataTrainingPath: NSTextField!
    @IBOutlet weak var dataSavePath: NSTextField!
    var visualizer: NSViewController?

    @IBOutlet weak var networkSavePath: NSTextField!
    @IBOutlet weak var gestureLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVisulization()
    }
    
    @IBAction func backClick(_ sender: AnyObject) {
        view.window?.contentViewController = visualizer
    }
    
    @IBAction func startRecordingClick(_ sender: AnyObject) {
        myo = Myo.init(appIdentifier: "com.votebin.brainco", updateTime: 100)  // Blocking UI update every 50ms
        myo?.delegate = self
        
        // Read teh file path
        if(dataSavePath.stringValue.characters.count > 0){
            fileOutputStream = OutputStream(toFileAtPath: dataSavePath.stringValue, append: false)
            fileOutputStream?.open()
        }
        myo?.connectWaiting(3000)
        myo?.startUpdate();
        trainingInstruction.stringValue = trainingLabelNames[currentTrainingLabel]

    }
    
    @IBAction func stopClick(_ sender: AnyObject) {
        stopRecording()
    }
    
    func setUpVisulization(){
        trainingCountLabel.stringValue = "\(0)/\(trainingDataSize)"
        
        // Magnitude bar chart implementation
        emgMagnitudeDataSet.colors = [AppTheme.BAR_COLORS[0]]
        emgMagnitudeData.addDataSet(emgMagnitudeDataSet)
        
        barChart.data = emgMagnitudeData
        barChart.gridBackgroundColor = NSUIColor.white
        barChart.chartDescription?.text = ""
        
    }
    
    // Data visualizing methods
    let emgMagnitudeData = BarChartData()
    let emgMagnitudeDataSet = BarChartDataSet(values: ([0,0,0,0,0,0,0,0].enumerated().map { x, y  in return BarChartDataEntry(x: Double(x), y: Double(y))}), label: "EMG Magnitude")

    func plotEmgMagnitudeIndicator(emgData: [Int32]){
        skipperCounter += 1
        if (skipperCounter == skipper){
            skipperCounter = 0
            for (index, emgValue) in emgData.enumerated() {
                // Use ABS after double
                emgMagnitudeDataSet.entryForIndex(index)?.y = abs(Double(emgValue))
            }
            emgMagnitudeDataSet.notifyDataSetChanged()
            barChart.notifyDataSetChanged()
        }
    }
    
    func writeEmgToFile(emgData: [Int32], timestamp: UInt64){
        if(activated){
            
            let inputs:[String] = emgData.map{String(Double($0)/128)} + Filter.filtered.map{String(Double($0)/Filter.WINDOW_SIZE_DOUBLE/128)} + [String(currentTrainingLabel)]
            
            let line = inputs.joined(separator: ",") + "\n"
            
            fileOutputStream?.write(line, maxLength: line.lengthOfBytes(using: String.Encoding.utf8))
        }
        
    }
    
    func plotQuadraticFilteredActivatorState(filtered:[Int32]){
        activated = Activation.quadraticFilteredActivation(filteredEmg: filtered)
        if activated {
            activationIndicator.activate()
        }else{
            if !TrainerVC.isTestingNetwork{
                if(activated != activationIndicator.activated){
                    resumeRecording()
                }
            }
            activationIndicator.deactivate()
        }
    }
    
    // Myo delegate methods
    func myo(onConnect myo: Myo!, firmwareVersion firmware: String!, timestamp: UInt64) {
        myoStatusLabel.stringValue = "Training started"
        startRecordingButton.isEnabled = false
    }
    
    func myo(onDisconnect myo: Myo!, timestamp: UInt64) {
        myoStatusLabel.stringValue = "Training stopped"
        startRecordingButton.isEnabled = true
    }
    
    func myo(_ myo: Myo!, onEmgData emgData: UnsafeMutablePointer<Int32>!, timestamp: UInt64) {
        let arrayEmgData = Array(UnsafeBufferPointer(start: emgData, count: 8))
        
        // NOTE: One extra loop involved here in filtering outside of loo[
        Filter.filter(emgData: arrayEmgData)
        plotEmgMagnitudeIndicator(emgData: arrayEmgData)
        plotQuadraticFilteredActivatorState(filtered: Filter.filtered)
        
        if TrainerVC.isTestingNetwork{
            
            // TODO: Implement a 10 frame delay
            if activated{
                var inputs:[Double] = arrayEmgData.map{Double($0)/128}
                inputs.append(contentsOf: Filter.filtered.map{Double($0)/Filter.WINDOW_SIZE_DOUBLE/128})

                let outputs = network.feedforward(Vector(inputs))
                let (_, labelInd) = max(outputs)
                
                Filter.recordDecision(outputLabel: labelInd)
                
                testSkipperCounter += 1
                if testSkipperCounter == testSkipper{
                    let finalLabel = Filter.makeDecision()
                    if finalLabel >= 0 {
                        gestureLabel.stringValue = TrainerVC.gestureLabelNames[labelInd]
                    }else{
                        gestureLabel.stringValue = "Relaxed"
                    }
                    testSkipperCounter = 0
                }
                
            }else{
                gestureLabel.stringValue = "Relaxed"
            }
            

        }else{
            // After applying filter
            if(activated && !waiting){
                trainingLabelCount[currentTrainingLabel] += 1
                
                trainingCountLabel.stringValue = "\(trainingLabelCount[currentTrainingLabel])/\(trainingDataSize)"
                writeEmgToFile(emgData: arrayEmgData, timestamp: timestamp)
                
                if(trainingLabelCount[currentTrainingLabel] >= trainingDataSize) {
                    pauseRecording()
                }
            }
        }
        

    }
    
    func pauseRecording(){
        
        currentTrainingLabel += 1
        if(currentTrainingLabel == trainingLabelCount.count){
            stopRecording()
            return
        }else{
            waiting = true
            trainingInstruction.stringValue = "Please relax ....."
            //trainingInstruction.stringValue = trainingLabelNames[currentTrainingLabel]
        }
    }
    
    func resumeRecording(){
        waiting = false
        TrainerVC.isTestingNetwork = false
        trainingInstruction.stringValue = trainingLabelNames[currentTrainingLabel]

    }

    @IBAction func startTrainingClick(_ sender: AnyObject) {
        MachineLearning.train(path: dataTrainingPath.stringValue)
    }
    @IBAction func saveNetworkClick(_ sender: AnyObject) {
        let success = MachineLearning.saveNetwork(path: networkSavePath.stringValue)
        if success {
            gestureLabel.stringValue = "Network saved"
        }
    }
    @IBAction func loadNetworkAndListenClick(_ sender: AnyObject) {
        let success = MachineLearning.loadNetwork(path: networkSavePath.stringValue)
        if success {
            gestureLabel.stringValue = "Network loaded"
            TrainerVC.isTestingNetwork = true
            
            myo = Myo.init(appIdentifier: "com.votebin.brainco", updateTime: 100)  // Blocking UI update every 50ms
            myo?.delegate = self
            myo?.connectWaiting(3000)
            myo?.startUpdate();
        }else{
            print("Failed to load network")
        }
    }
    
    func stopRecording(){
        startRecordingButton.isEnabled = true
        activated = false
        currentTrainingLabel = 0
        trainingLabelCount = [0,0,0,0]
        trainingInstruction.stringValue = "Training finished"
        myo?.stopUpdate()
        fileOutputStream?.close()
    }
    
}
