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

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController
{
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var texture: MTLTexture!

    let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setUpMetal()
        setUpTexture()
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
        
        let region = MTLRegionMake2D(0, 0, Int(imageWidth), Int(imageHeight))
  
        texture.replaceRegion(region, mipmapLevel: 0, withBytes: &rawData, bytesPerRow: Int(bytesPerRow))
    }
    
    
    
    func setUpMetal()
    {
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: nil)
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0).pixelFormat = .BGRA8Unorm
        
        var pipelineError : NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
        if pipelineState == nil
        {
            println("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()
        
        timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
 
    func render()
    {
        let drawable = metalLayer.nextDrawable()  // simon
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0).texture = drawable.texture
        renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0).loadAction = .Clear
        renderPassDescriptor.colorAttachments.objectAtIndexedSubscript(0).clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        if let renderEncoder = renderEncoderOpt {
            renderEncoder.setRenderPipelineState(pipelineState)
            
            renderEncoder.setFragmentTexture(texture, atIndex: 0)
            
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
    
    func gameloop()
    {
        autoreleasepool
        {
            self.render()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

