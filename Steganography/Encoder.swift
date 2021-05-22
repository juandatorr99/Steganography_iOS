//
//  Encoder.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

class Encoder {
    
    static func encode(image: UIImage, text: String) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let inputCGImage = copy!.cgImage!
        let width = inputCGImage.width
        let height = inputCGImage.height
        let bytesPerRow = BytesPerPixel * width
        
        if width * height * BytesPerPixel < text.count * BitsPerComponent {
            print("Error: you need a larger image or a smaller text")
            return nil
        }
        
        var flagEnd = 0
        
        let binaryData = Data(text.utf8)
        var binaryString = binaryData.reduce("") { (acc, byte) -> String in
            var transformed = String(byte, radix: 2)
            while transformed.count < BitsPerComponent {
                transformed = "0" + transformed
            }
            return acc + transformed
        }
        binaryString += "00000000"

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
        
        for row in 0 ..< width {
            for column in 0 ..< height {
                let index = row * width + column
                let indexText = (row * width + column) * 3
                
                var r = pixelBuffer[index].redComponent
                var g = pixelBuffer[index].greenComponent
                var b = pixelBuffer[index].blueComponent
                let a = pixelBuffer[index].alphaComponent

                if indexText > binaryString.count {
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if binaryString[indexText] == "0" {
                    r = r & ~1
                } else {
                    r = r | 1
                }
                
                if indexText + 1 > binaryString.count {
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if binaryString[indexText + 1] == "0" {
                    g = g & ~1
                } else {
                    g = g | 1
                }
                
                if indexText > binaryString.count {
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if binaryString[indexText + 2] == "0" {
                    b = b & ~1
                } else {
                    b = b | 1
                }

                pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
            }
            
            if flagEnd == 1 {
                break
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage)
        
        return outputImage
    }
}
