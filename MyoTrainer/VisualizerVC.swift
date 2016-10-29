//
//  ViewController.swift
//  MyoTrainer
//
//  Created by Innovation on 10/27/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa
import Charts

class VisualizerVC: NSViewController, MyoDelegate{

    var myo:Myo = Myo.init(appIdentifier: "com.votebin.brainco", updateTime: 50)  // Blocking UI update every 50ms
    var fileOutputStream:OutputStream?
    
    let skipper = 20
    var skipperCounter = 0
    
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var writeToFileCheckBox: NSButton!
    @IBOutlet weak var filePathField: NSTextField!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var lineChart0: LineChartView!
    @IBOutlet weak var lineChart1: LineChartView!
    @IBOutlet weak var lineChart2: LineChartView!
    @IBOutlet weak var lineChart3: LineChartView!
    @IBOutlet weak var lineChart4: LineChartView!
    @IBOutlet weak var lineChart5: LineChartView!
    @IBOutlet weak var lineChart6: LineChartView!
    @IBOutlet weak var lineChart7: LineChartView!
    
    var lineCharts:[LineChartView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        myo.delegate = self
        setUpVisulization()
    }
    /*
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    */

    @IBAction func connectClick(_ sender: AnyObject) {
        // Read teh file path
        if(filePathField.stringValue.characters.count > 0){
            fileOutputStream = OutputStream(toFileAtPath: filePathField.stringValue, append: true)
            fileOutputStream?.open()
        }
        myo.connectWaiting(3000)
        myo.startUpdate();
    }
    @IBAction func stopClick(_ sender: AnyObject) {
        myo.stopUpdate()
        fileOutputStream?.close()
    }
    
    // Data properties
    let emgMagnitudeData = BarChartData()
    let barDataSerie = BarChartDataSet(values: ([0,0,0,0,0,0,0,0].enumerated().map { x, y  in return BarChartDataEntry(x: Double(x), y: Double(y))}), label: "EMG Magnitude")

    func setUpVisulization(){
        // Magnitude bar chart implementation
        barDataSerie.colors = [AppTheme.BAR_COLOR]
        emgMagnitudeData.addDataSet(barDataSerie)
        
        barChart.data = emgMagnitudeData
        barChart.gridBackgroundColor = NSUIColor.white
        barChart.chartDescription?.text = ""
        
        // Time serie line chart implementation
        lineCharts = [lineChart0,lineChart1,lineChart2,lineChart3,lineChart4,lineChart5,lineChart6,lineChart7]
        for (ind, lineChart) in lineCharts.enumerated() {
            
        }
    }
    
    // Utility function implementation
    
    func writeEmgToFile(emgData: [Int8], timestamp: UInt64){
        let line = "\(emgData[0]),\(emgData[1]),\(emgData[2]),\(emgData[3]),\(emgData[4]),\(emgData[5]),\(emgData[6]),\(emgData[7]),\(timestamp)\n"
        fileOutputStream?.write(line, maxLength: line.lengthOfBytes(using: String.Encoding.utf8))
    }
    
    func plotEmgMagnitudeIndicator(emgData: [Int8]){
        skipperCounter += 1
        if (skipperCounter == skipper){
            skipperCounter = 0
            for (index, magnitude) in emgData.enumerated() {
                // Use ABS after double
                barDataSerie.entryForIndex(index)?.y = abs(Double(magnitude))
            }
            emgMagnitudeData.notifyDataChanged()
            barChart.notifyDataSetChanged()
        }
        
    }
    
    func plotEmgSignalLineChart(emgData:[Int8]){
        
    }
    
    // Myo delegate methods
    
    func myo(onConnect myo: Myo!, firmwareVersion firmware: String!, timestamp: UInt64) {
        statusLabel.stringValue = "Connected"
        connectButton.isEnabled = false
    }
    
    func myo(onDisconnect myo: Myo!, timestamp: UInt64) {
        statusLabel.stringValue = "Disconnected"
        connectButton.isEnabled = true
    }
    
    func myo(_ myo: Myo!, onEmgData emgData: UnsafeMutablePointer<Int8>!, timestamp: UInt64) {
        let arrayEmgData = Array(UnsafeBufferPointer(start: emgData, count: 8))
        // Before applying filter
        if(writeToFileCheckBox.state == NSOnState){
            writeEmgToFile(emgData: arrayEmgData, timestamp: timestamp)
        }
        plotEmgMagnitudeIndicator(emgData: arrayEmgData)
        // print(arrayEmgData)
    }
    
    
}

