//
//  ViewController.swift
//  MyoTrainer
//
//  Created by Disi A on 10/27/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa
import Charts

class VisualizerVC: NSViewController, MyoDelegate{
    
    var trainerVC: TrainerVC?
    
    var myo:Myo?
    var fileOutputStream:OutputStream?
    
    let skipper = 20
    var skipperCounter = 0
    
    let lineSignalSkipper = 10
    var lineSignalSkipperCounter = 0
    var activated = false
    
    @IBOutlet weak var startButton: NSButton!
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

    @IBOutlet weak var activationIndicator: ActivationIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVisulization()
        initializeData()
    }
    /*
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    */
    
    func initializeData(){
        Filter.initializeFilter()
    }

    @IBAction func startClick(_ sender: AnyObject) {
        myo = Myo.init(appIdentifier: "com.votebin.brainco", updateTime: 50)  // Blocking UI update every 50ms
        myo?.delegate = self

        // Read teh file path
        if(filePathField.stringValue.characters.count > 0){
            fileOutputStream = OutputStream(toFileAtPath: filePathField.stringValue, append: true)
            fileOutputStream?.open()
        }
        myo?.connectWaiting(3000)
        myo?.startUpdate();
    }
    @IBAction func stopClick(_ sender: AnyObject) {
        myo?.stopUpdate()
        fileOutputStream?.close()
    }

    func setUpVisulization(){
        
        // Magnitude bar chart implementation
        emgMagnitudeDataSet.colors = [AppTheme.BAR_COLORS[0]]
        emgFilteredMagnitudeDataSet.colors = [AppTheme.BAR_COLORS[1]]
        emgMagnitudeData.addDataSet(emgMagnitudeDataSet)
        emgMagnitudeData.addDataSet(emgFilteredMagnitudeDataSet)
        
        barChart.data = emgMagnitudeData
        barChart.gridBackgroundColor = NSUIColor.white
        barChart.chartDescription?.text = ""
        
        // Time series line chart implementation
        lineCharts = [lineChart0,lineChart1,lineChart2,lineChart3,lineChart4,lineChart5,lineChart6,lineChart7]
        
        for (ind, lineChart) in lineCharts.enumerated() {
            let dataSet = LineChartDataSet(values: DataFactory.LINE_CHART_DEFAULT_DATA.map {$0}, label: "Sensor \(ind + 1)")
            dataSet.colors = [AppTheme.LINE_COLORS[ind]]
            lineChartsDataSet.append(dataSet)
            let lineChartData = LineChartData()
            lineChartData.addDataSet(dataSet)
            lineChartsData.append(lineChartData)
            lineChart.data = lineChartData
            
            lineChart.gridBackgroundColor = NSUIColor.white
            lineChart.chartDescription?.text = ""
        }
    }
    
    // Utility function implementation
    
    func writeEmgToFile(emgData: [Int32], timestamp: UInt64){
        let line = "\(emgData[0]),\(emgData[1]),\(emgData[2]),\(emgData[3]),\(emgData[4]),\(emgData[5]),\(emgData[6]),\(emgData[7]),\(timestamp)\n"
        fileOutputStream?.write(line, maxLength: line.lengthOfBytes(using: String.Encoding.utf8))
    }
    
    // Data visualizing methods
    let emgMagnitudeData = BarChartData()
    let emgMagnitudeDataSet = BarChartDataSet(values: ([0,0,0,0,0,0,0,0].enumerated().map { x, y  in return BarChartDataEntry(x: Double(x), y: Double(y))}), label: "EMG Mag")
    
    let emgFilteredMagnitudeDataSet = BarChartDataSet(values: (Filter.filtered.enumerated().map { x, y  in return BarChartDataEntry(x: Double(x), y: Double(y))}), label: "EMG Filtered Mag")
    
    func plotEmgMagnitudeIndicator(emgData: [Int32]){
        skipperCounter += 1
        if (skipperCounter == skipper){
            skipperCounter = 0

            for (index, emgValue) in emgData.enumerated() {
                // Use ABS after double
                emgMagnitudeDataSet.entryForIndex(index)?.y = abs(Double(emgValue))
                emgFilteredMagnitudeDataSet.entryForIndex(index)?.y = Double(Filter.filtered[index])/Filter.WINDOW_SIZE_DOUBLE
            }
            
            emgFilteredMagnitudeDataSet.notifyDataSetChanged()
            // emgMagnitudeData.notifyDataChanged()
            emgMagnitudeDataSet.notifyDataSetChanged()
            barChart.notifyDataSetChanged()
        }
    }

    var lineCharts:[LineChartView] = []
    // var lineChartsData :[[ChartDataEntry]] = []
    var lineChartsDataSet :[ChartDataSet] = []
    var lineChartsData :[LineChartData] = []
    
    func plotEmgSignalLineChart(emgData:[Int32]){
        lineSignalSkipperCounter += 1
        if (lineSignalSkipperCounter == lineSignalSkipper){
            lineSignalSkipperCounter = 0
            for (ind, emgValue) in emgData.enumerated() {
                //lineCharts
                _ = lineChartsDataSet[ind].removeFirst()
                let lastDataEntry = lineChartsDataSet[ind].getLast()!
                _ = lineChartsDataSet[ind].addEntry(ChartDataEntry(x: lastDataEntry.x + 1, y: Double(emgValue)))
                lineChartsData[ind].notifyDataChanged()
                lineCharts[ind].notifyDataSetChanged()
            }
        }
    }
    
    func plotQuadraticFilteredActivatorState(filtered:[Int32]){
        activated = Activation.quadraticFilteredActivation(filteredEmg: filtered)
        if activated {
            activationIndicator.activate()
        }else{
            activationIndicator.deactivate()
        }
    }
    
    func plotNNLogisticActivatorState(filtered:[Int32]){
        activated = Activation.logisticStepForFilteredEmg(filteredEmg: filtered)
        if activated {
            activationIndicator.activate()
        }else{
            activationIndicator.deactivate()
        }
    }
    
    func plotSimpleActivatorState(emgData:[Int32]){
        activated = Activation.activateSimple(emgData: emgData)
        if activated {
            activationIndicator.activate()
        }else{
            activationIndicator.deactivate()
        }
    }
    
    // Myo delegate methods
    func myo(onConnect myo: Myo!, firmwareVersion firmware: String!, timestamp: UInt64) {
        statusLabel.stringValue = "Connected"
        startButton.isEnabled = false
    }
    
    func myo(onDisconnect myo: Myo!, timestamp: UInt64) {
        statusLabel.stringValue = "Disconnected"
        startButton.isEnabled = true
    }
    
    func myo(_ myo: Myo!, onEmgData emgData: UnsafeMutablePointer<Int32>!, timestamp: UInt64) {
        let arrayEmgData = Array(UnsafeBufferPointer(start: emgData, count: 8))
        // Before applying filter
        if(writeToFileCheckBox.state == NSOnState){
            writeEmgToFile(emgData: arrayEmgData, timestamp: timestamp)
        }
        
        // NOTE: One extra loop involved here in filtering outside of loo[
        Filter.filter(emgData: arrayEmgData)
        
        plotEmgMagnitudeIndicator(emgData: arrayEmgData)
        plotEmgSignalLineChart(emgData: arrayEmgData)
        // plotSimpleActivatorState(emgData: arrayEmgData)
        //plotNNLogisticActivatorState(filtered: Filter.filtered)
        plotQuadraticFilteredActivatorState(filtered: Filter.filtered)
    }
    
    @IBAction func trainClick(_ sender: AnyObject) {
        // Start training interface
        trainerVC = storyboard?.instantiateController(withIdentifier: "TrainerVC") as! TrainerVC

        trainerVC?.visualizer = self
        view.window?.contentViewController = trainerVC
        /*
        if let window = view.window { // where window.styleMask & NSFullScreenWindowMask > 0
            // adjust view size to current window

        }
        */
        
        // presentViewController(trainerVC, animator: self)
    }
    
    
}

