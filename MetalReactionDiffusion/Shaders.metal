//
//  Shaders.metal
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 18/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void kernelShader(texture2d<float, access::read> inTexture [[texture(0)]],
                              texture2d<float, access::write> outTexture [[texture(1)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float4 inColor = inTexture.read(gid);
    float value = dot(inColor.rgb, float3(0.299, 0.587, 0.114));
    float4 grayColor(value, value, value, 1.0);
    float4 outColor = mix(grayColor, inColor, 0.0);
    outTexture.write(outColor, gid);
}