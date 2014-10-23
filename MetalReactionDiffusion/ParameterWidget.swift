//
//  ParameterWidget.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ParameterWidget: UIControl
{
    let label = UILabel(frame: CGRectZero)
    let slider = UISlider(frame: CGRectZero)

    override func didMoveToSuperview()
    {
        label.textColor = UIColor.whiteColor()
        layer.backgroundColor = UIColor.darkGrayColor().CGColor
        
        layer.cornerRadius = 5
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        
        addSubview(label)
        addSubview(slider)
        
        slider.addTarget(self, action: "sliderChangeHandler", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func sliderChangeHandler()
    {
        value = slider.value
        
        popoulateLabel()
        
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func popoulateLabel()
    {
        if let fieldName = fitzhughNagumoFieldName
        {
            label.text = fieldName.rawValue + " = " + NSString(format: "%.6f", value)
        }
    }
    
    var fitzhughNagumoFieldName: FitzhughNagumoFieldNames?
    {
        didSet
        {
            popoulateLabel();
        }
    }
    
    var value: Float = 0
    {
        didSet
        {
            slider.value = value
            popoulateLabel()
        }
    }
    
    var minimumValue: Float = 0
    {
        didSet
        {
            slider.minimumValue = minimumValue
        }
    }
    
    var maximumValue: Float = 1
    {
        didSet
        {
            slider.maximumValue = maximumValue
        }
    }
    
    override func layoutSubviews()
    {
        label.frame = CGRect(x: 5, y: -3, width: frame.width, height: frame.height / 2)
        slider.frame = CGRect(x: 0, y: frame.height - 30, width: frame.width, height: frame.height / 2)
    }
    
}
