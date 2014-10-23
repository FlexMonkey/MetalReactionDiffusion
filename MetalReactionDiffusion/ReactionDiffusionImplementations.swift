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
    let name = "FitzhughNagumo"
 
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


