//
//  ViewController.swift
//  MyoTrainer
//
//  Created by Innovation on 10/27/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa

class VisualizerVC: NSViewController, MyoDelegate{

    var myo:Myo = Myo.init(appIdentifier: "com.votebin.brainco", updateTime: 50)  // Blocking UI update every 50ms
    
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myo.delegate = self
        // myo = (NSApplication.shared().delegate as! AppDelegate).myo
        // Do any additional setup after loading the view.
    }
    /*
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }*/

    @IBAction func connectClick(_ sender: AnyObject) {
        myo.connectWaiting(3000)
        myo.startUpdate();
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
        let arrayData = Array(UnsafeBufferPointer(start: emgData, count: 8))
        print(arrayData)
    }
    
}

