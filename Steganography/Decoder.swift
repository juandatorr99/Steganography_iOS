//
//  Decoder.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

class Decoder {
    
    static func decode(image:UIImage) -> String? {
        let inputCGImage = image.cgImage!
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerRow = BytesPerPixel * width
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: BitsPerComponent, bytesPerRow: bytesPerRow, space: ColorSpace, bitmapInfo: BitmapInfo) else {
            print("Error: unable to create context")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("Error: unable to get context data")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        //Check if first values are 0
        var indexCheck = 0
        while indexCheck < 2 {
            
            if pixelBuffer[indexCheck].redComponent & 1 == 1 {
                return nil
            }
            
            if pixelBuffer[indexCheck].greenComponent & 1 == 1  {
                return nil
            }
            
            if pixelBuffer[indexCheck].blueComponent & 1 == 1 && indexCheck != 2  {
                return nil
            }
            indexCheck += 1
        }
        var count = 1
        var result = "0"
        if pixelBuffer[2].blueComponent & 1 == 1{
            result = "1"
            count = 0
        }
        
        var i = 3
        
        while true {
            var lr = "0"
            var lg = "0"
            var lb = "0"
            
            if pixelBuffer[i].redComponent & 1 == 1 {
                count = 0
                lr = "1"
            } else {
                count += 1
            }
            
            result = result +  lr
            
            if count == BitsPerComponent {
                break
            }
            
            if pixelBuffer[i].greenComponent & 1 == 1{
                count = 0
                lg = "1"
            } else {
                count += 1
            }
            
            result = result + lg
            
            if count == BitsPerComponent {
                break
            }
            
            if pixelBuffer[i].blueComponent & 1 == 1{
                count = 0
                lb = "1"
            } else {
                count += 1
            }
            
            result = result + lb
            
            if count == BitsPerComponent {
                break
            }
            
            i += 1
        }
        
        var index = result.startIndex
        var message: String = ""
        for _ in 0 ..< result.count / BitsPerComponent {
            let nextIndex = result.index(index, offsetBy: BitsPerComponent)
            let charBits = result[index ..< nextIndex]
            message += String(UnicodeScalar(UInt8(charBits, radix: 2)!))
            index = nextIndex
        }
        
        return message != "" ? message : nil
    }
    
}
