//
//  ReactionDiffusion.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation

struct FitzhughNagumo
{
    let name = "FitzhughNagumo"
    
    var reactionDiffusionStruct = FitzhughNagumoParameters()
    
    let fieldNames = [FitzhughNagumoFieldNames.timestep,
                FitzhughNagumoFieldNames.a0,
                FitzhughNagumoFieldNames.a1,
                FitzhughNagumoFieldNames.epsilon,
                FitzhughNagumoFieldNames.delta,
                FitzhughNagumoFieldNames.k1,
                FitzhughNagumoFieldNames.k2,
                FitzhughNagumoFieldNames.k3]
    
    func getValueForFieldName(fieldName: FitzhughNagumoFieldNames) -> Float
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
        }
        
        return returnValue
    }
    
    mutating func setValueForFieldName(fieldName: FitzhughNagumoFieldNames, value: Float)
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
        }
    }
    
    func getMinMaxForFieldName(fieldName: FitzhughNagumoFieldNames) -> (min: Float, max: Float)
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
        }
        
        return returnValue
    }
    
    
}

enum FitzhughNagumoFieldNames: String
{
    case timestep = "Timestep"
    case a0 = "a0"
    case a1 = "a1"
    case epsilon = "Epsilon"
    case delta = "Delta"
    case k1 = "k1"
    case k2 = "k2"
    case k3 = "k3"
}

struct FitzhughNagumoParameters
{
    var timestep: Float = 0.1
    var a0: Float = 0.2199
    var a1: Float = 0.7000
    var epsilon: Float = 0.6387
    var delta: Float = 2.5400
    var k1: Float = 2.0550
    var k2: Float = 2.0092
    var k3: Float = 0.5563
}