//
//  Shaders.metal
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 18/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct FitzhughNagumoParameters
{
    float timestep;
    float a0;
    float a1;
    float epsilon;
    float delta;
    float k1;
    float k2;
    float k3;
};

/*
    Fitzhugh-Nagumo reaction diffusion
 
    Implementation based on https://code.google.com/p/reaction-diffusion/
 */
kernel void fitzhughNagumoShader(texture2d<float, access::read> inTexture [[texture(0)]],
                         texture2d<float, access::write> outTexture [[texture(1)]],
                         constant FitzhughNagumoParameters &params [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    uint2 northIndex(gid.x, gid.y - 1);
    uint2 southIndex(gid.x, gid.y + 1);
    uint2 westIndex(gid.x - 1, gid.y);
    uint2 eastIndex(gid.x + 1, gid.y);
    
    float3 northColor = inTexture.read(northIndex).rgb;
    float3 southColor = inTexture.read(southIndex).rgb;
    float3 westColor = inTexture.read(westIndex).rgb;
    float3 eastColor = inTexture.read(eastIndex).rgb;
    
    float3 thisColor = inTexture.read(gid).rgb;
    
    float2 laplacian = (northColor.rb + southColor.rb + westColor.rb + eastColor.rb) - (4.0 * thisColor.rb);
    float laplacian_a = laplacian.r;
    float laplacina_b = laplacian.g;
    float a = thisColor.r;
    float b = thisColor.b;

    
    float delta_a = (params.k1 * a) - (params.k2 * a * a) - (a * a * a) - b + laplacian_a;
    float delta_b = params.epsilon * (params.k3 * a - params.a1 * b - params.a0) + params.delta * laplacina_b;
    
    float4 outColor(a + (params.timestep * delta_a), a + (params.timestep * delta_a), b + (params.timestep * delta_b), 1);
    outTexture.write(outColor, gid);
    
}

kernel void grayScottShader(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    float F = 0.028;
    float K = 0.098;
    float Du = 0.136;
    float Dv = 0.026;
    
    uint2 northIndex(gid.x, gid.y - 1);
    uint2 southIndex(gid.x, gid.y + 1);
    uint2 westIndex(gid.x - 1, gid.y);
    uint2 eastIndex(gid.x + 1, gid.y);
    
    float3 northColor = inTexture.read(northIndex).rgb;
    float3 southColor = inTexture.read(southIndex).rgb;
    float3 westColor = inTexture.read(westIndex).rgb;
    float3 eastColor = inTexture.read(eastIndex).rgb;
                    
    float3 thisColor = inTexture.read(gid).rgb;
    
    float2 laplacian = (northColor.rb + southColor.rb + westColor.rb + eastColor.rb) - (4.0 * thisColor.rb);
    
    float reactionRate = thisColor.r * thisColor.b * thisColor.b;
    
    float u = thisColor.r + (Du * laplacian.r) - reactionRate + F * (1.0 - thisColor.r);
    float v = thisColor.b + (Dv * laplacian.g) + reactionRate - K * thisColor.b;
    
 
    float4 outColor(u, u, v, 1);
    outTexture.write(outColor, gid);
}



