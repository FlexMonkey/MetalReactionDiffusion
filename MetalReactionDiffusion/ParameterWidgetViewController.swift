//
//  ParameterWidgetViewController.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 30/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ParameterWidgetViewController: UIViewController {

    let slider = UISlider(frame: CGRectZero)
    
    override func viewDidLoad()
    {
        if let prefWidth = UIApplication.sharedApplication().keyWindow?.layer.frame.height
        {
            preferredContentSize = CGSize(width: prefWidth - 40, height: 55)
        }
        
        view.addSubview(slider)
        
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews()
    {
        slider.frame = view.frame
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
