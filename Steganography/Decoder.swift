//
//  Decoder.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

class Decoder {
    
    func decode(image:UIImage) -> String? {
        let inputCGImage = image.cgImage!
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        var result = ""
        var i = 0
        var count0 = 0
        while true {
            var lr = "0"
            var lg = "0"
            var lb = "0"
            
            if pixelBuffer[i].redComponent & 1 == 1 {
                count0 = 0
                lr = "1"
            }else{
                count0 += 1
            }
            result = result +  lr
            if count0 == 8 {
                break
            }
            
            if pixelBuffer[i].greenComponent & 1 == 1{
                count0 = 0
                lg = "1"
            }else{
                count0 += 1
            }
            result = result + lg
            if count0 == 8 {
                break
            }
            
            if pixelBuffer[i].blueComponent & 1 == 1{
                count0 = 0
                lb = "1"
            }else{
                count0 += 1
            }
            result = result + lb
            if count0 == 8 {
                break
            }
            i+=1
        }
        
        var index = result.startIndex
        var message: String = ""
        for _ in 0..<result.count/8 {
            let nextIndex = result.index(index, offsetBy: 8)
            let charBits = result[index..<nextIndex]
            message += String(UnicodeScalar(UInt8(charBits, radix: 2)!))
            index = nextIndex
        }
        
        return message
    }
}
