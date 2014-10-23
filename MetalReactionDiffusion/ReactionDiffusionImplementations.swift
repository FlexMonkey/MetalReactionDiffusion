//
//  ReactionDiffusion.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation

class FitzhughNagumo: ReactionDiffusionBase, ReactionDiffusion
{
    let name = "FitzHugh–Nagumo"
 
    let shaderName = "fitzhughNagumoShader"
    
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
    let name = "Gray-Scott"
    
    let shaderName = "-"
    
    let fieldNames = [ReactionDiffusionFieldNames.timestep]
}

class BelousovZhabotinsky: ReactionDiffusionBase, ReactionDiffusion
{
    let name = "Belousov-Zhabotinsky"
    
    let shaderName = "-"
    
    let fieldNames = [ReactionDiffusionFieldNames.timestep]
}