//
//  ReactionDiffusionProtocol.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 23/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation

protocol ReactionDiffusion
{
    var name: String { get }
    var fieldNames: [ReactionDiffusionFieldNames] { get }
    var shaderName: String { get }
    
    var reactionDiffusionStruct: ReactionDiffusionParameters { get set }
    
    func getValueForFieldName(fieldName: ReactionDiffusionFieldNames) -> Float
    func setValueForFieldName(fieldName: ReactionDiffusionFieldNames, value: Float)
    func getMinMaxForFieldName(fieldName: ReactionDiffusionFieldNames) -> (min: Float, max: Float)
    
    func resetParameters()
}