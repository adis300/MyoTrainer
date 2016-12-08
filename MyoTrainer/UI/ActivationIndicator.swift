//
//  ActivationIndicator.swift
//  MyoTrainer
//
//  Created by Disi A on 10/29/16.
//  Copyright © 2016 Votebin. All rights reserved.
//

import Cocoa

class ActivationIndicator : NSView{
    
    var activated = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setBackgroundAndBorder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundAndBorder()
    }

    func setBackgroundAndBorder(color: NSColor = AppTheme.ACTIVATION_COLORS[0]) {
        
        wantsLayer = true
        
        layer?.backgroundColor = color.cgColor
        layer?.cornerRadius = 8
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.gray.cgColor
        layer?.masksToBounds = true
        
    }
    
    func activate(){
        if(!activated) {
            activated = true
            layer?.backgroundColor = AppTheme.ACTIVATION_COLORS[1].cgColor
        }
    }
    
    func deactivate(){
        if(activated){
            activated = false
            layer?.backgroundColor = AppTheme.ACTIVATION_COLORS[0].cgColor
        }
    }
    
}
