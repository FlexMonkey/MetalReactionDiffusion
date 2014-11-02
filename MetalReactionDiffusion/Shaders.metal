//
//  Shaders.metal
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 18/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//
// todo: https://code.google.com/p/reaction-diffusion/source/browse/trunk/Ready/Patterns/Yang2006/jumping.vti
// todo: https://www.youtube.com/watch?v=JhipxYrgNvI


#include <metal_stdlib>
using namespace metal;

struct ReactionDiffusionParameters
{
    // Fitzhugh-Nagumo
    
    float timestep;
    float a0;
    float a1;
    float epsilon;
    float delta;
    float k1;
    float k2;
    float k3;
    
    // Gray Scott
    
    float F;
    float K;
    float Du;
    float Dv;
    
    // Belousov
    
    float alpha;
    float beta;
    float gamma;
};

/*
    Fitzhugh-Nagumo reaction diffusion
 
    Implementation based on https://code.google.com/p/reaction-diffusion/
 */
    kernel void fitzhughNagumoShader(texture2d<float, access::read> inTexture [[texture(0)]],
                             texture2d<float, access::write> outTexture [[texture(1)]],
                             constant ReactionDiffusionParameters &params [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
    {
        const uint2 northIndex(gid.x, gid.y - 1);
        const uint2 southIndex(gid.x, gid.y + 1);
        const uint2 westIndex(gid.x - 1, gid.y);
        const uint2 eastIndex(gid.x + 1, gid.y);
        
        const float2 northColor = inTexture.read(northIndex).rb;
        const float2 southColor = inTexture.read(southIndex).rb;
        const float2 westColor = inTexture.read(westIndex).rb;
        const float2 eastColor = inTexture.read(eastIndex).rb;
        
        const float2 thisColor = inTexture.read(gid).rb;
        
        const float2 laplacian = (northColor.rg + southColor.rg + westColor.rg + eastColor.rg) - (4.0 * thisColor.rg);
        const float laplacian_a = laplacian.r;
        const float laplacian_b = laplacian.g;
        
        const float a = thisColor.r;
        const float b = thisColor.g;

        const float delta_a = (params.k1 * a) - (params.k2 * a * a) - (a * a * a) - b + laplacian_a;
        const float delta_b = params.epsilon * (params.k3 * a - params.a1 * b - params.a0) + params.delta * laplacian_b;
        
        const float4 outColor(a + (params.timestep * delta_a), a + (params.timestep * delta_a), b + (params.timestep * delta_b), 1);
        
        outTexture.write(outColor, gid);
    }



kernel void grayScottShader(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant ReactionDiffusionParameters &params [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    const uint2 northIndex(gid.x, gid.y - 1);
    const uint2 southIndex(gid.x, gid.y + 1);
    const uint2 westIndex(gid.x - 1, gid.y);
    const uint2 eastIndex(gid.x + 1, gid.y);

    const float2 northColor = inTexture.read(northIndex).rb;
    const float2 southColor = inTexture.read(southIndex).rb;
    const float2 westColor = inTexture.read(westIndex).rb;
    const float2 eastColor = inTexture.read(eastIndex).rb;
 
    const float2 thisColor = inTexture.read(gid).rb;

    const float2 laplacian = (northColor.rg + southColor.rg + westColor.rg + eastColor.rg) - (4.0f * thisColor.rg);
    
    const float reactionRate = thisColor.r * thisColor.g * thisColor.g;
    
    float u = thisColor.r + (params.Du * laplacian.r) - reactionRate + params.F * (1.0f - thisColor.r);
    float v = thisColor.g + (params.Dv * laplacian.g) + reactionRate - (params.F + params.K) * thisColor.g;

    
    const float4 outColor(u, u, v, 1);
    outTexture.write(outColor, gid);
}

kernel void belousovZhabotinskyShader(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant ReactionDiffusionParameters &params [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    
    float3 accumColor = inTexture.read(gid).rgb;
    
    for (int j = -1; j <= 1; j++)
    {
        for (int i = -1; i <= 1; i++)
        {
            uint2 kernelIndex(gid.x + i, gid.y + j);
            accumColor += inTexture.read(kernelIndex).rgb;
        }
    }
    
    accumColor.rgb = accumColor.rgb / 9.0f;
    
    float a = accumColor.r + accumColor.r * (params.alpha * params.gamma * accumColor.g) - accumColor.b;
    float b = accumColor.g + accumColor.g * ((params.beta * accumColor.b) - (params.alpha * accumColor.r));
    float c = accumColor.b + accumColor.b * ((params.gamma * accumColor.r) - (params.beta * accumColor.g));
    
    float4 outColor(a, b, c, 1);
    outTexture.write(outColor, gid);
}




