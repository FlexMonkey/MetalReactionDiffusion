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
    let label = UILabel(frame: CGRectZero)
    var requestedReactionDiffusionModel : ReactionDiffusionModels?

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
        
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.whiteColor()
        
        addSubview(label)
        
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
                //createUserInterface()
            }
            createUserInterface()
        }
    }

    func displayCallout()
    {
        // work in progress! Refactor to create once, draw list of possible models from seperate class....
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let fitzhughNagumoAction = UIAlertAction(title: ReactionDiffusionModels.FitzHughNagumo.rawValue, style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        let grayScottAction = UIAlertAction(title: ReactionDiffusionModels.GrayScott.rawValue, style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        let belousovZhabotinskyAction = UIAlertAction(title: ReactionDiffusionModels.BelousovZhabotinsky.rawValue, style: UIAlertActionStyle.Default, handler: reactionDiffusionModelChangeHandler)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: saveActionHandler)
        let loadAction = UIAlertAction(title: "Browse and Load", style: UIAlertActionStyle.Default, handler: loadActionHandler)
        let aboutAction = UIAlertAction(title: "About", style: UIAlertActionStyle.Default, handler: aboutActionHandler)
        
        alertController.addAction(belousovZhabotinskyAction)
        alertController.addAction(fitzhughNagumoAction)
        alertController.addAction(grayScottAction)
        
        alertController.addAction(saveAction)
        alertController.addAction(loadAction)
        alertController.addAction(aboutAction)
        
        if let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController
        {
            if let popoverPresentationController = alertController.popoverPresentationController
            {
                let xx = menuButton.frame.origin.x + frame.origin.x
                let yy = menuButton.frame.origin.y + frame.origin.y
                
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Right
                
                popoverPresentationController.sourceRect = CGRect(x: xx, y: yy, width: menuButton.frame.width, height: menuButton.frame.height)
                popoverPresentationController.sourceView = viewController.view

                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    func reactionDiffusionModelChangeHandler(value: UIAlertAction!) -> Void
    {
        requestedReactionDiffusionModel = ReactionDiffusionModels(rawValue: value.title)
        
        sendActionsForControlEvents(UIControlEvents.ModelChanged)
    }
    
    func saveActionHandler(value: UIAlertAction!) -> Void
    {
        sendActionsForControlEvents(UIControlEvents.SaveModel)
    }
    
    func loadActionHandler(value: UIAlertAction!) -> Void
    {
        sendActionsForControlEvents(UIControlEvents.LoadModel)
    }
    
    func aboutActionHandler(value: UIAlertAction!) -> Void
    {
        let alertController = UIAlertController(title: "ReDiLab v1.0\nReaction Diffusion Laboratory", message: "\nSimon Gladman | November 2014", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        let openBlogAction = UIAlertAction(title: "Open Blog", style: .Default, handler: visitFlexMonkey)
        
        alertController.addAction(okAction)
        alertController.addAction(openBlogAction)
        
        if let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController
        {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func visitFlexMonkey(value: UIAlertAction!)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://flexmonkey.blogspot.co.uk")!)
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
        label.text = reactionDiffusionModel.model.rawValue
        
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
            widget.addTarget(self, action: "resetSimulation", forControlEvents: UIControlEvents.ResetSimulation)
 
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
        
        menuButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        
        label.frame = CGRect(x: 40, y: 10, width: frame.width - 40 - 10, height: 30)
    }

}

extension UIControlEvents
{
    static let ResetSimulation: UIControlEvents = UIControlEvents(0x01000000)
    static let ModelChanged: UIControlEvents = UIControlEvents(0x02000000)
    static let SaveModel: UIControlEvents = UIControlEvents(0x04000000)
    static let LoadModel: UIControlEvents = UIControlEvents(0x08000000)
}
