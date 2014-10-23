//
//  ReactionDiffusionEditor.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ReactionDiffusionEditor: UIControl
{
    var parameterWidgets = [ParameterWidget]()

    var reactionDiffusionModel: FitzhughNagumo!
    {
        didSet
        {
            if oldValue == nil || oldValue.name != reactionDiffusionModel.name
            {
                createUserInterface()
            }
        }
    }

    func createUserInterface()
    {
        for widget in parameterWidgets
        {
            var varWidget: ParameterWidget? = widget
            
            varWidget!.removeFromSuperview()
            varWidget = nil
        }
        
        parameterWidgets = [ParameterWidget]()
        
        for fieldName in reactionDiffusionModel.fieldNames
        {
            let widget = ParameterWidget(frame: CGRectZero)
            
            parameterWidgets.append(widget)
            
            widget.minimumValue = reactionDiffusionModel.getMinMaxForFieldName(fieldName).min
            widget.maximumValue = reactionDiffusionModel.getMinMaxForFieldName(fieldName).max
      
            widget.value = reactionDiffusionModel.getValueForFieldName(fieldName)
            widget.fitzhughNagumoFieldName = fieldName
            
            widget.addTarget(self, action: "widgetChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
            
            addSubview(widget)
        }
        
        setNeedsLayout()
    }
    
    func widgetChangeHandler(widget: ParameterWidget)
    {
        if let fieldName = widget.fitzhughNagumoFieldName
        {
            reactionDiffusionModel.setValueForFieldName(fieldName, value: widget.value)
            
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func layoutSubviews()
    {
        layer.backgroundColor = UIColor.darkGrayColor().CGColor

        for (idx: Int, widget: ParameterWidget) in enumerate(parameterWidgets)
        {
            widget.frame = CGRect(x: 10, y: 40 + idx * 80, width: Int(frame.width - 20), height: 55)
        }
    }

}
