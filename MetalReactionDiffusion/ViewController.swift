//
//  ViewController.swift
//  MetalReactionDiffusion
//
//  Created by Simon Gladman on 18/10/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//
//  Thanks to http://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started
//  Thanks to https://twitter.com/steipete/status/473952933684330497
//  Thanks to http://metalbyexample.com/textures-and-samplers/
//  Thanks to http://metalbyexample.com/introduction-to-compute/

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController
{
    var defaultLibrary: MTLLibrary! = nil
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil

    var texture: MTLTexture!
    
    var outTexture: MTLTexture!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setUpMetal()

        //-----
   
        
        // let imageView =  UIImageView(frame: CGRectMake(0, 0, 200, 200))
     
    }

    func setUpTexture()
    {
        let image = UIImage(named: "grand_canyon.jpg")
        let imageRef = image.CGImage
        
        let imageWidth = CGImageGetWidth(imageRef)
        let imageHeight = CGImageGetHeight(imageRef)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = UInt(8)
        let bytesPerRow = bytesPerPixel * imageWidth
        let bitsPerComponent = UInt(8)
        var rawData = [UInt](count: Int(imageWidth * imageHeight * 4), repeatedValue: 0)
  
        let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Big.toRaw() | CGImageAlphaInfo.PremultipliedLast.toRaw())

        let context = CGBitmapContextCreate(&rawData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(imageWidth), CGFloat(imageHeight)), imageRef)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA16Unorm, width: Int(imageWidth), height: Int(imageHeight), mipmapped: true)
        
        texture = device.newTextureWithDescriptor(textureDescriptor)
        
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(texture.pixelFormat, width: Int(imageWidth), height: Int(imageHeight), mipmapped: false)
        outTexture = device.newTextureWithDescriptor(outTextureDescriptor)
        
        let region = MTLRegionMake2D(0, 0, Int(imageWidth), Int(imageHeight))
  
        texture.replaceRegion(region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: Int(bytesPerRow))
    }
 
    func setUpMetal()
    {
        device = MTLCreateSystemDefaultDevice()
     
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
        
        let kernelFunction = defaultLibrary.newFunctionWithName("kernelShader")
        device.newComputePipelineStateWithFunction(kernelFunction!, completionHandler: computePipelineReady)
    }
 
    func computePipelineReady(value: MTLComputePipelineState!, error: NSError!) -> Void
    {
        setUpTexture()
        
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(value)
        commandEncoder.setTexture(texture, atIndex: 0)
        commandEncoder.setTexture(outTexture, atIndex: 1)
        
        // let buffer = device.newBufferWithLength(outTexture.arrayLength, options: MTLResourceOptions.OptionCPUCacheModeDefault)
        // commandEncoder.setBuffer(buffer, offset: 0, atIndex: 1)

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(texture.width / threadGroupCount.width, texture.height / threadGroupCount.height, 1)
        
        commandQueue = device.newCommandQueue()
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
    }
     override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

