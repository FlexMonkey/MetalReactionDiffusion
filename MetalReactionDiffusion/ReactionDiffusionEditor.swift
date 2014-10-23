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
    let toolbar = UIToolbar(frame: CGRectZero)

    override func didMoveToSuperview()
    {
        let resetSimulationButton = UIBarButtonItem(title: "Reset Sim", style: UIBarButtonItemStyle.Plain, target: self, action: "resetSimulation")
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let resetParametersButton = UIBarButtonItem(title: "Reset Params", style: UIBarButtonItemStyle.Plain, target: self, action: "resetParameters")
        
        toolbar.items = [resetSimulationButton, spacer, resetParametersButton]
        
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        
        addSubview(toolbar)
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowOpacity = 1
    }
    
    var reactionDiffusionModel: ReactionDiffusion!
    {
        didSet
        {
            if oldValue == nil || oldValue.name != reactionDiffusionModel.name
            {
                createUserInterface()
            }
        }
    }

    func resetSimulation()
    {
        sendActionsForControlEvents(UIControlEvents.ResetSimulation)
    }
    
    func resetParameters()
    {
        reactionDiffusionModel.resetParameters()
        
        for widget in parameterWidgets
        {
            widget.value = reactionDiffusionModel.getValueForFieldName(widget.reactionDiffusionFieldName!)
        }
        
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
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
            widget.reactionDiffusionFieldName = fieldName
            
            widget.addTarget(self, action: "widgetChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
            
            addSubview(widget)
        }
        
        setNeedsLayout()
    }
    
    func widgetChangeHandler(widget: ParameterWidget)
    {
        if let fieldName = widget.reactionDiffusionFieldName
        {
            reactionDiffusionModel.setValueForFieldName(fieldName, value: widget.value)
            
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override func layoutSubviews()
    {
        layer.backgroundColor = UIColor.darkGrayColor().CGColor

        toolbar.frame = CGRect(x: 0, y: frame.height - 40, width: frame.width, height: 40)
        
        for (idx: Int, widget: ParameterWidget) in enumerate(parameterWidgets)
        {
            widget.frame = CGRect(x: 10, y: 10 + idx * 80, width: Int(frame.width - 20), height: 55)
        }
    }

}

extension UIControlEvents
{
    static let ResetSimulation: UIControlEvents = UIControlEvents(0x00000001 << 24)
}
