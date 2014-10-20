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
    let bitmapInfo = CGBitmapInfo(CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
    let renderingIntent = kCGRenderingIntentDefault
    
    let bytesPerPixel = UInt(4)
    let bitsPerComponent = UInt(8)
    let bitsPerPixel:UInt = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    
    var pipelineState: MTLComputePipelineState!
    var defaultLibrary: MTLLibrary! = nil
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil

    let imageView =  UIImageView(frame: CGRectZero)
    let slider = UISlider(frame: CGRectZero)
    
    var textureA: MTLTexture!
    var textureB: MTLTexture!
    var useTextureAForInput : Bool = true
    
    var saturationFactor: Float = 0
    
    var imageSize:CGSize!
    var imageByteCount: Int!
    
    var image:UIImage!
    
    var threadGroupCount:MTLSize!
    var threadGroups: MTLSize!
    
    var fitzhughNagumoParameters = FitzhughNagumoParameters()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(imageView)
        
        /*
        slider.minimumValue = 0
        slider.maximumValue = 5

        slider.addTarget(self, action: "sliderChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(slider)
        */

        setUpMetal()
    }

    func sliderChangeHandler(value: UISlider)
    {
        saturationFactor = slider.value
        
        applyFilter()
    }
    
    func setUpMetal()
    {
        device = MTLCreateSystemDefaultDevice()
        
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
        
        let kernelFunction = defaultLibrary.newFunctionWithName("fitzhughNagumoShader")
        pipelineState = device.newComputePipelineStateWithFunction(kernelFunction!, error: nil)
        
        setUpTexture()
        run()
    }
    
    func run()
    {
        Async.background()
        {
            self.image = self.applyFilter()
        }
        .main
        {
            self.imageView.image = self.image
            self.useTextureAForInput = !self.useTextureAForInput
            self.run()
        }
    }
    
    func setUpTexture()
    {
        let image = UIImage(named: "noisyBox.jpg")
        let imageRef = image?.CGImage!
        
        let imageWidth = CGImageGetWidth(imageRef)
        let imageHeight = CGImageGetHeight(imageRef)
  
        threadGroupCount = MTLSizeMake(8, 8, 1)
        threadGroups = MTLSizeMake(Int(imageWidth) / threadGroupCount.width, Int(imageHeight) / threadGroupCount.height, 1)
        
        let bytesPerRow = bytesPerPixel * imageWidth
        
        imageSize = CGSize(width: Int(imageWidth), height: Int(imageHeight))
        imageByteCount = Int(imageSize.width * imageSize.height * 4)
        
        var rawData = [UInt8](count: Int(imageWidth * imageHeight * 4), repeatedValue: 0)

        let context = CGBitmapContextCreate(&rawData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, rgbColorSpace, bitmapInfo)
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(imageWidth), CGFloat(imageHeight)), imageRef)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA8Unorm, width: Int(imageWidth), height: Int(imageHeight), mipmapped: false)
        
        textureA = device.newTextureWithDescriptor(textureDescriptor)
        
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(textureA.pixelFormat, width: textureA.width, height: textureA.height, mipmapped: false)
        textureB = device.newTextureWithDescriptor(outTextureDescriptor)
        
        let region = MTLRegionMake2D(0, 0, Int(imageWidth), Int(imageHeight))
        textureA.replaceRegion(region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: Int(bytesPerRow))
    }


    
    final func applyFilter() -> UIImage
    {
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        
        commandEncoder.setComputePipelineState(pipelineState)
        
        if useTextureAForInput
        {
            commandEncoder.setTexture(textureA, atIndex: 0)
            commandEncoder.setTexture(textureB, atIndex: 1)
        }
        else
        {
            commandEncoder.setTexture(textureB, atIndex: 0)
            commandEncoder.setTexture(textureA, atIndex: 1)
        }
 
        var buffer: MTLBuffer = device.newBufferWithBytes(&fitzhughNagumoParameters, length: sizeof(FitzhughNagumoParameters), options: nil)
        commandEncoder.setBuffer(buffer, offset: 0, atIndex: 0)
       

        commandQueue = device.newCommandQueue()
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // write image....
   
        let bytesPerRow = bytesPerPixel * UInt(imageSize.width)
        var imageBytes = [UInt8](count: imageByteCount, repeatedValue: 0)
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        
        if useTextureAForInput
        {
            textureB.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)
        }
        else
        {
            textureA.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)
        }
        
        let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: &imageBytes, length: imageBytes.count * sizeof(UInt8)))
       
        let imageRef = CGImageCreate(UInt(imageSize.width), UInt(imageSize.height), bitsPerComponent, bitsPerPixel, bytesPerRow, rgbColorSpace, bitmapInfo, providerRef, nil, false, renderingIntent)

        
        return UIImage(CGImage: imageRef)!
    }
 
    override func viewDidLayoutSubviews()
    {
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        slider.frame = CGRect(x: 20, y: view.frame.height - 50, width: view.frame.width - 40, height: 50)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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

