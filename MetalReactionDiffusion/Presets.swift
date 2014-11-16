//
//  Presets.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 16/11/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import Foundation


class Worms: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.049023
        reactionDiffusionStruct.K = 0.070117
        reactionDiffusionStruct.Du = 0.172852
        reactionDiffusionStruct.Dv = 0.058594
    }
}

class Spots: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.033945
        reactionDiffusionStruct.K = 0.067461
        reactionDiffusionStruct.Du = 0.144531
        reactionDiffusionStruct.Dv = 0.046387
    }
}

class SpottyBifurcation: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.023867
        reactionDiffusionStruct.K = 0.0725
        reactionDiffusionStruct.Du = 0.194824
        reactionDiffusionStruct.Dv = 0.010254
    }
}

class Strings: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.050391
        reactionDiffusionStruct.K = 0.070508
        reactionDiffusionStruct.Du = 0.182129
        reactionDiffusionStruct.Dv = 0.062012
    }
}

class Bifurcation: GrayScott
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.F = 0.023867
        reactionDiffusionStruct.K = 0.0725
        reactionDiffusionStruct.Du = 0.194824
        reactionDiffusionStruct.Dv = 0.010254
    }
}



class Liquid: FitzhughNagumo
{
    override init()
    {
        super.init()
 
        reactionDiffusionStruct.timestep = 0.02
        reactionDiffusionStruct.a0 = 0.289062
        reactionDiffusionStruct.a1 = 0.177734
        reactionDiffusionStruct.epsilon = 1.152344
        reactionDiffusionStruct.delta = 1.25
        reactionDiffusionStruct.k1 = 2.099600
        reactionDiffusionStruct.k2 = 0.083008
        reactionDiffusionStruct.k3 = 1.723
    }
}

class SpiralCoral: FitzhughNagumo
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.timestep = 0.02
        reactionDiffusionStruct.a0 = 0.664062
        reactionDiffusionStruct.a1 = 0.451172
        reactionDiffusionStruct.epsilon = 0.136719
        reactionDiffusionStruct.delta = 4.0
        reactionDiffusionStruct.k1 = 1.645508
        reactionDiffusionStruct.k2 = 0.0097
        reactionDiffusionStruct.k3 = 2.2314
        
    }
}

class ExcitedLines: FitzhughNagumo
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.timestep = 0.1
        reactionDiffusionStruct.a0 = 0.219900
        reactionDiffusionStruct.a1 = 0.7
        reactionDiffusionStruct.epsilon = 0.638700
        reactionDiffusionStruct.delta = 2.54
        reactionDiffusionStruct.k1 = 2.055
        reactionDiffusionStruct.k2 = 2.00920
        reactionDiffusionStruct.k3 = 0.5563
    }
}

/*
class Pulsing: FitzhughNagumo
{
override init()
{
super.init()

reactionDiffusionStruct.timestep = 0.01864
reactionDiffusionStruct.a0 = 0.359375
reactionDiffusionStruct.a1 = 0.785156
reactionDiffusionStruct.epsilon = 1.671875
reactionDiffusionStruct.delta = 4.0
reactionDiffusionStruct.k1 = 1.000977
reactionDiffusionStruct.k2 = 0.590820
reactionDiffusionStruct.k3 = 2.241211
}
}

class SmallSpiralWavefronts: FitzhughNagumo
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.timestep = 0.012794
        reactionDiffusionStruct.a0 = 0.359375
        reactionDiffusionStruct.a1 = 0.785156
        reactionDiffusionStruct.epsilon = 0.628906
        reactionDiffusionStruct.delta = 4.0
        reactionDiffusionStruct.k1 = 1.567383
        reactionDiffusionStruct.k2 = 0.034861
        reactionDiffusionStruct.k3 = 2.2314
    }
}

class SpiralCoral: FitzhughNagumo
{
    override init()
    {
        super.init()
        
        reactionDiffusionStruct.timestep = 0.02
        reactionDiffusionStruct.a0 = 0.664062
        reactionDiffusionStruct.a1 = 0.451172
        reactionDiffusionStruct.epsilon = 0.136719
        reactionDiffusionStruct.delta = 4.0
        reactionDiffusionStruct.k1 = 1.645508
        reactionDiffusionStruct.k2 = 0.0097
        reactionDiffusionStruct.k3 = 2.2314
        
    }
}
*/
