//
//  Encoder.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

class Encoder {
    
    func encode(image: UIImage, text: String) -> UIImage?{
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let inputCGImage = copy!.cgImage!
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        
        if width * height * 4 < text.length*8 {
            print("Error")
            return nil
        }
        
        var flagEnd = 0
        
        let binaryData = Data(text.utf8)
        var stringOf01 = binaryData.reduce("") { (acc, byte) -> String in
            var transformed = String(byte, radix: 2)
            while transformed.count < 8 {
                transformed = "0" + transformed
            }
            return acc + transformed
        }
        stringOf01 += "00000000"

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
        
        for row in 0 ..< Int(width) {
            for column in 0 ..< Int(height) {
                let index = row * width + column
                let indexText = ((row * width) + column) * 3
                
                var r = pixelBuffer[index].redComponent
                var g = pixelBuffer[index].greenComponent
                var b = pixelBuffer[index].blueComponent
                let a = pixelBuffer[index].alphaComponent

                if indexText > stringOf01.length {
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if stringOf01[indexText] == "0" {
                    r = r & ~1
                }else{
                    r = r | 1
                }
                
                if indexText+1 > stringOf01.length{
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if stringOf01[indexText+1] == "0" {
                    g = g & ~1
                }else{
                    g = g | 1
                }
                
                if indexText > stringOf01.length {
                    flagEnd = 1
                    pixelBuffer[index] = RGBA32(red: r, green: g,   blue: b,   alpha: a)
                    break
                }
                
                if stringOf01[indexText+2] == "0" {
                    b = b & ~1
                }else{
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


extension String {
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

struct RGBA32: Equatable {
    private var color: UInt32
    
    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}
