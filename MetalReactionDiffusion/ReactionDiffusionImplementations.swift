//
//  ReactionDiffusion.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

class FitzhughNagumo: ReactionDiffusionBase, ReactionDiffusion
{
    let model = ReactionDiffusionModels.FitzHughNagumo
 
    let shaderName = "fitzhughNagumoShader"
    
    let initalImage: UIImage = UIImage(named: "noisySquare.jpg")!
    
    let fieldNames = [ReactionDiffusionFieldNames.timestep,
                ReactionDiffusionFieldNames.a0,
                ReactionDiffusionFieldNames.a1,
                ReactionDiffusionFieldNames.epsilon,
                ReactionDiffusionFieldNames.delta,
                ReactionDiffusionFieldNames.k1,
                ReactionDiffusionFieldNames.k2,
                ReactionDiffusionFieldNames.k3]
}

class GrayScott: ReactionDiffusionBase, ReactionDiffusion
{
    let model = ReactionDiffusionModels.GrayScott
    
    let shaderName = "grayScottShader"
    
    let initalImage = UIImage(named: "grayScottNoisySquare.jpg")!
    
    let fieldNames = [ReactionDiffusionFieldNames.F, ReactionDiffusionFieldNames.K, ReactionDiffusionFieldNames.Du, ReactionDiffusionFieldNames.Dv]
}

/*
class BelousovZhabotinsky: ReactionDiffusionBase, ReactionDiffusion
{
    let model = ReactionDiffusionModels.BelousovZhabotinsky
    
    let shaderName = "-"
    
    let fieldNames = [ReactionDiffusionFieldNames.timestep]
}
*/