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
    
    let imageSide: UInt = 640
    let imageSize = CGSize(width: Int(640), height: Int(640))
    let imageByteCount = Int(640 * 640 * 4)
    
    let bytesPerPixel = UInt(4)
    let bitsPerComponent = UInt(8)
    let bitsPerPixel:UInt = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bytesPerRow = UInt(4 * 640)
    let providerLength = Int(640 * 640 * 4) * sizeof(UInt8)
    var imageBytes = [UInt8](count: Int(640 * 640 * 4), repeatedValue: 0)
    
    var pipelineState: MTLComputePipelineState!
    var defaultLibrary: MTLLibrary! = nil
    var device: MTLDevice! = nil
    var commandQueue: MTLCommandQueue! = nil

    let imageView =  UIImageView(frame: CGRectZero)
    let editor = ReactionDiffusionEditor(frame: CGRectZero)
    
    var region: MTLRegion!
    var textureA: MTLTexture!
    var textureB: MTLTexture!
    var useTextureAForInput = true
    var resetSimulationFlag = false

    var image:UIImage!
    var runTime = CFAbsoluteTimeGetCurrent()
    
    var threadGroupCount:MTLSize!
    var threadGroups: MTLSize!

    var reactionDiffusionModel: ReactionDiffusion = FitzhughNagumo()
    var requestedReactionDiffusionModel: ReactionDiffusionModels?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        view.addSubview(imageView)
        view.addSubview(editor)
        
        editor.reactionDiffusionModel = reactionDiffusionModel
        editor.addTarget(self, action: "editorChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
        editor.addTarget(self, action: "resetSimulationHandler", forControlEvents: UIControlEvents.ResetSimulation)
        editor.addTarget(self, action: "modelChangedHandler:", forControlEvents: UIControlEvents.ModelChanged)

        setUpMetal()
    }

    final func modelChangedHandler(value: ReactionDiffusionEditor)
    {
        if value.requestedReactionDiffusionModel != nil
        {
            requestedReactionDiffusionModel = value.requestedReactionDiffusionModel!
        }
    }
    
    final func editorChangeHandler(value: ReactionDiffusionEditor)
    {
        reactionDiffusionModel.reactionDiffusionStruct = value.reactionDiffusionModel.reactionDiffusionStruct
    }
    
    func setUpMetal()
    {
        device = MTLCreateSystemDefaultDevice()
        
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
        
        let kernelFunction = defaultLibrary.newFunctionWithName(reactionDiffusionModel.shaderName)
        pipelineState = device.newComputePipelineStateWithFunction(kernelFunction!, error: nil)
        
        setUpTexture()
        run()
    }

    func resetSimulationHandler()
    {
        resetSimulationFlag = true
    }
    
    final func run()
    {
        Async.background()
        {
            self.image = self.applyFilter()
        }
        .main
        {
            self.imageView.image = self.image
            self.useTextureAForInput = !self.useTextureAForInput
            
            if self.resetSimulationFlag && self.useTextureAForInput
            {
                self.resetSimulationFlag = false
                
                self.setUpTexture()
            }
            
            if self.requestedReactionDiffusionModel != nil && self.useTextureAForInput
            {
                let foo = self.requestedReactionDiffusionModel!
                
                switch foo
                {
                    case .GrayScott:
                        self.reactionDiffusionModel = GrayScott()
                    case .FitzHughNagumo:
                        self.reactionDiffusionModel = FitzhughNagumo()
                }
                
                self.requestedReactionDiffusionModel = nil
                self.editor.reactionDiffusionModel = self.reactionDiffusionModel
            
                let kernelFunction = self.defaultLibrary.newFunctionWithName(self.reactionDiffusionModel.shaderName)
                self.pipelineState = self.device.newComputePipelineStateWithFunction(kernelFunction!, error: nil)
            }
            
            self.run()
            
            let fps = Int( 1 / (CFAbsoluteTimeGetCurrent() - self.runTime))
            println("\(fps) fps")
            self.runTime = CFAbsoluteTimeGetCurrent()
        }
    }

    func setUpTexture()
    {
        let imageRef = reactionDiffusionModel.initalImage.CGImage!

        threadGroupCount = MTLSizeMake(16, 16, 1)
        threadGroups = MTLSizeMake(Int(imageSide) / threadGroupCount.width, Int(imageSide) / threadGroupCount.height, 1)

        var rawData = [UInt8](count: Int(imageSide * imageSide * 4), repeatedValue: 0)

        let context = CGBitmapContextCreate(&rawData, imageSide, imageSide, bitsPerComponent, bytesPerRow, rgbColorSpace, bitmapInfo)
        
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(imageSide), CGFloat(imageSide)), imageRef)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA8Unorm, width: Int(imageSide), height: Int(imageSide), mipmapped: false)
        
        textureA = device.newTextureWithDescriptor(textureDescriptor)
        
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(textureA.pixelFormat, width: textureA.width, height: textureA.height, mipmapped: false)
        textureB = device.newTextureWithDescriptor(outTextureDescriptor)
        
        region = MTLRegionMake2D(0, 0, Int(imageSide), Int(imageSide))
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
 
        var buffer: MTLBuffer = device.newBufferWithBytes(&reactionDiffusionModel.reactionDiffusionStruct, length: sizeof(ReactionDiffusionParameters), options: nil)
        commandEncoder.setBuffer(buffer, offset: 0, atIndex: 0)
 
        commandQueue = device.newCommandQueue()

        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        if useTextureAForInput
        {
            textureB.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)
        }
        else
        {
            textureA.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)
        }
        
        let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: &imageBytes, length: providerLength))
       
        let imageRef = CGImageCreate(UInt(imageSize.width), UInt(imageSize.height), bitsPerComponent, bitsPerPixel, bytesPerRow, rgbColorSpace, bitmapInfo, providerRef, nil, false, renderingIntent)

        return UIImage(CGImage: imageRef)!
    }

    
    override func viewDidLayoutSubviews()
    {
        let imageSide = view.frame.height - topLayoutGuide.length
        
        imageView.frame = CGRect(x: 0, y: topLayoutGuide.length, width: imageSide, height: imageSide)
     
        let editorWidth = CGFloat(view.frame.width - imageSide)
        
        editor.frame = CGRect(x: imageSide, y: topLayoutGuide.length, width: editorWidth, height: imageSide)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> Int
    {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
}



