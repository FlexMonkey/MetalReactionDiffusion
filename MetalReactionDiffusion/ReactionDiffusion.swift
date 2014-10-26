//
//  ReactionDiffusionProtocol.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit

protocol ReactionDiffusion
{
    var model: ReactionDiffusionModels { get }
    var fieldNames: [ReactionDiffusionFieldNames] { get }
    var shaderName: String { get }
    
    var initalImage: UIImage { get }
    
    var reactionDiffusionStruct: ReactionDiffusionParameters { get set }
    
    func getValueForFieldName(fieldName: ReactionDiffusionFieldNames) -> Float
    func setValueForFieldName(fieldName: ReactionDiffusionFieldNames, value: Float)
    func getMinMaxForFieldName(fieldName: ReactionDiffusionFieldNames) -> (min: Float, max: Float)
    
    func resetParameters()
}

class ReactionDiffusionBase
{
    var reactionDiffusionStruct = ReactionDiffusionParameters()
    
    func resetParameters()
    {
        reactionDiffusionStruct = ReactionDiffusionParameters()
    }
    
    func getValueForFieldName(fieldName: ReactionDiffusionFieldNames) -> Float
    {
        var returnValue: Float = 0.0
        
        switch(fieldName)
        {
        case .timestep:
            returnValue = reactionDiffusionStruct.timestep
        case .a0:
            returnValue = reactionDiffusionStruct.a0
        case .a1:
            returnValue = reactionDiffusionStruct.a1
        case .epsilon:
            returnValue = reactionDiffusionStruct.epsilon
        case .delta:
            returnValue = reactionDiffusionStruct.delta
        case .k1:
            returnValue = reactionDiffusionStruct.k1
        case .k2:
            returnValue = reactionDiffusionStruct.k2
        case .k3:
            returnValue = reactionDiffusionStruct.k3
            
        case .F:
            returnValue = reactionDiffusionStruct.F
        case .K:
            returnValue = reactionDiffusionStruct.K
        case .Du:
            returnValue = reactionDiffusionStruct.Du
        case .Dv:
            returnValue = reactionDiffusionStruct.Dv
            
        case .alpha:
            returnValue = reactionDiffusionStruct.alpha
        case .beta:
            returnValue = reactionDiffusionStruct.beta
        case .gamma:
            returnValue = reactionDiffusionStruct.gamma
        }
        
        return returnValue
    }
    
    func setValueForFieldName(fieldName: ReactionDiffusionFieldNames, value: Float)
    {
        switch(fieldName)
        {
        case .timestep:
            reactionDiffusionStruct.timestep = value
        case .a0:
            reactionDiffusionStruct.a0 = value
        case .a1:
            reactionDiffusionStruct.a1 = value
        case .epsilon:
            reactionDiffusionStruct.epsilon = value
        case .delta:
            reactionDiffusionStruct.delta = value
        case .k1:
            reactionDiffusionStruct.k1 = value
        case .k2:
            reactionDiffusionStruct.k2 = value
        case .k3:
            reactionDiffusionStruct.k3 = value
            
        case .F:
            reactionDiffusionStruct.F = value
        case .K:
            reactionDiffusionStruct.K = value
        case .Du:
            reactionDiffusionStruct.Du = value
        case .Dv:
            reactionDiffusionStruct.Dv = value
            
        case .alpha:
            reactionDiffusionStruct.alpha = value
        case .beta:
            reactionDiffusionStruct.beta = value
        case .gamma:
            reactionDiffusionStruct.gamma = value
        }
    }
    
    func getMinMaxForFieldName(fieldName: ReactionDiffusionFieldNames) -> (min: Float, max: Float)
    {
        var returnValue: (min: Float, max: Float) = (min: 0.0, max: 0.0)
        
        switch(fieldName)
        {
        case .timestep:
            returnValue = (min: 0.0001, max: 0.25)
        case .a0, .a1:
            returnValue = (min: 0.0, max: 1.0)
        case .epsilon:
            returnValue = (min: 0.0, max: 2.0)
        case .delta:
            returnValue = (min: 0.0, max: 4.0)
        case .k1, .k2, .k3:
            returnValue = (min: 0.0, max: 2.5)
        case .F, .K:
            returnValue = (min: 0.0, max: 0.1)
        case .Du, .Dv:
            returnValue = (min: 0.0, max: 0.25)
        case .alpha, .beta, .gamma:
            returnValue = (min: -0.5, max: 1.5)
            
        }
        
        return returnValue
    }
}

enum ReactionDiffusionModels: String
{
    case FitzHughNagumo = "FitzHugh–Nagumo"
    case GrayScott = "Gray-Scott"
    case BelousovZhabotinsky = "Belousov-Zhabotinsky"
}

enum ReactionDiffusionFieldNames: String
{
    // Fitzhugh-Nagumo
    
    case timestep = "Timestep"
    case a0 = "a₀"
    case a1 = "a₁"
    case epsilon = "Epsilon"
    case delta = "Delta"
    case k1 = "k₁"
    case k2 = "k₂"
    case k3 = "k₃"
    
    // Gray Scott
    
    case F = "F"
    case K = "K"
    case Du = "Du"
    case Dv = "Dv"
    
    // Belousov-Zhabotinsky
    
    case alpha = "Alpha"
    case beta = "Beta"
    case gamma = "Gamma"
}

struct ReactionDiffusionParameters
{
    // Fitzhugh-Nagumo
    
    var timestep: Float = 0.02
    var a0: Float = 0.289062
    var a1: Float = 0.177734
    var epsilon: Float = 1.152344
    var delta: Float = 1.25
    var k1: Float = 2.0996
    var k2: Float = 0.083008
    var k3: Float = 1.723
    
    // Gray Scott
    
    var F: Float = 0.057031
    var K: Float = 0.063672
    var Du: Float = 0.155762
    var Dv: Float = 0.0644
    
    // Belousov-Zhabotinsky
    
    var alpha: Float = 1.0
    var beta: Float = 1.0
    var gamma: Float = 1.0
    
}