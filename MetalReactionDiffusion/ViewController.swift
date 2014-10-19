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
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.toRaw())
    
    var defaultLibrary: MTLLibrary! = nil
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil

    let imageView =  UIImageView(frame: CGRectMake(0, 0, 200, 200))
    
    var texture: MTLTexture!
    
    var outTexture: MTLTexture!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        view.addSubview(imageView)
        
        setUpMetal()
    }

    func setUpTexture()
    {
        let image = UIImage(named: "grand_canyon.jpg")
        let imageRef = image.CGImage
        
        let imageWidth = CGImageGetWidth(imageRef)
        let imageHeight = CGImageGetHeight(imageRef)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = UInt(4)
        let bytesPerRow = bytesPerPixel * imageWidth
        let bitsPerComponent = UInt(8)
        var rawData = [UInt8](count: Int(imageWidth * imageHeight * 4), repeatedValue: 0)
  
        let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Big.toRaw() | CGImageAlphaInfo.PremultipliedLast.toRaw())

        let context = CGBitmapContextCreate(&rawData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(imageWidth), CGFloat(imageHeight)), imageRef)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA8Unorm, width: Int(imageWidth), height: Int(imageHeight), mipmapped: true)
        
        texture = device.newTextureWithDescriptor(textureDescriptor)
        
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: false)
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

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(texture.width / threadGroupCount.width, texture.height / threadGroupCount.height, 1)
        
        commandQueue = device.newCommandQueue()
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // write image....
        
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let imageByteCount = Int(imageSize.width * imageSize.height * 4)
        let bytesPerPixel = UInt(4)
        let bitsPerComponent = UInt(8)
        let bitsPerPixel:UInt = 32
        let bytesPerRow = bytesPerPixel * UInt(imageSize.width)
        var imageBytes = [UInt8](count: imageByteCount, repeatedValue: 0)
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        
        outTexture.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)

        let providerRef = CGDataProviderCreateWithCFData(
            NSData(bytes: &imageBytes, length: imageBytes.count * sizeof(UInt8))
        )
        
       let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Big.toRaw() | CGImageAlphaInfo.PremultipliedLast.toRaw())
        let renderingIntent = kCGRenderingIntentDefault
        
        let imageRef = CGImageCreate(UInt(imageSize.width), UInt(imageSize.height), bitsPerComponent, bitsPerPixel, bytesPerRow, rgbColorSpace, bitmapInfo, providerRef, nil, false, renderingIntent)
        
       imageView.image = UIImage(CGImage: imageRef)
        
       imageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
    }
    
    override func viewDidLayoutSubviews()
    {
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

