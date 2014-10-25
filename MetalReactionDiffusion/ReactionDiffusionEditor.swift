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
    let menuButton = UIButton(frame: CGRectZero)

    override func didMoveToSuperview()
    {
        let resetSimulationButton = UIBarButtonItem(title: "Reset Sim", style: UIBarButtonItemStyle.Plain, target: self, action: "resetSimulation")
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let resetParametersButton = UIBarButtonItem(title: "Reset Params", style: UIBarButtonItemStyle.Plain, target: self, action: "resetParameters")
        
        toolbar.items = [resetSimulationButton, spacer, resetParametersButton]
        
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        
        addSubview(toolbar)
        
        menuButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        menuButton.layer.borderWidth = 1
        menuButton.layer.cornerRadius = 5
        
        menuButton.showsTouchWhenHighlighted = true
        menuButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        menuButton.setImage(UIImage(named: "hamburger.png"), forState: UIControlState.Normal)

        menuButton.addTarget(self, action: "displayCallout", forControlEvents: UIControlEvents.TouchDown)
        
        addSubview(menuButton)
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: -1, height: 2)
        layer.shadowOpacity = 1
    }
    
    var reactionDiffusionModel: ReactionDiffusion!
    {
        didSet
        {
            if oldValue == nil || oldValue.model.rawValue != reactionDiffusionModel.model.rawValue
            {
                createUserInterface()
            }
        }
    }

    func displayCallout()
    {
        // work in progress! Refactor to create once, draw list of possible models from seperate class....
        
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fitzhughNagumoAction = UIAlertAction(title: ReactionDiffusionModels.FitzHughNagumo.rawValue, style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        let grayScottAction = UIAlertAction(title: ReactionDiffusionModels.GrayScott.rawValue, style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        let belousovZhabotinskyAction = UIAlertAction(title: "Belousov-Zhabotinsky", style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        
        alertController.addAction(belousovZhabotinskyAction)
        alertController.addAction(fitzhughNagumoAction)
        alertController.addAction(grayScottAction)
        
        if let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController
        {
            if let popoverPresentationController = alertController.popoverPresentationController
            {
                let xx = menuButton.frame.origin.x + frame.origin.x
                let yy = menuButton.frame.origin.y + frame.origin.y
                
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Right
                
                popoverPresentationController.sourceRect = CGRect(x: xx, y: yy, width: menuButton.frame.width, height: menuButton.frame.height)
                popoverPresentationController.sourceView = viewController.view
                
                popoverPresentationController
                
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    var requestedReactionDiffusionModel : ReactionDiffusionModels?
    
    func reactionDiffusionModelChangeHandler(value: UIAlertAction!) -> Void
    {
        requestedReactionDiffusionModel = ReactionDiffusionModels(rawValue: value.title)
        
        sendActionsForControlEvents(UIControlEvents.ModelChanged)
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
        menuButton.setTitle(reactionDiffusionModel.model.rawValue, forState: UIControlState.Normal)
        menuButton.titleLabel?.sizeToFit()
        
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
            widget.frame = CGRect(x: 10, y: 60 + idx * 80, width: Int(frame.width - 20), height: 55)
        }
        
        menuButton.frame = CGRect(x: 10, y: 10, width: Int(frame.width - 20), height: 30)
        menuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        menuButton.titleLabel?.textAlignment = NSTextAlignment.Right

        menuButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        menuButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
    }

}

extension UIControlEvents
{
    static let ResetSimulation: UIControlEvents = UIControlEvents(0x01000000)
    static let ModelChanged: UIControlEvents = UIControlEvents(0x02000000)
}
