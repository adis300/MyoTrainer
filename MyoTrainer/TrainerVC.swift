//
//  TrainerVC.swift
//  MyoTrainer
//
//  Created by Disi A on 11/27/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa

class TrainerVC: NSViewController {
    
    var visualizer: NSViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backClick(_ sender: AnyObject) {
        view.window?.contentViewController = visualizer
    }
    
    
    
    
    
}
