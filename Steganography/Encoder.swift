//
//  Encoder.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

let BITS_PER_COMPONENT = 8
let BYTES_PER_PIXEL = 4
let BYTES_OF_LENGTH = 4
let INITIAL_SHIFT = 7
let MIN_PIXELS = INFO_LENGTH + (DATA_PREFIX.length + DATA_SUFFIX.length) * BITS_PER_COMPONENT

func colorToStep(step: Int) -> Int {
    if (step % 3 == 0) {
        return 2
    } else if (step % 2 == 0) {
        return 1
    } else {
        return 0
    }
}

class Encoder {
    private var currentShift: Int?
    private var currentCharacter: Int?
    private var currentDataToHide: String?
    private var step = Int()
    
    func getStegoImageFor(image: UIImage, text: String, error: inout NSError?) -> UIImage? {
        let inputCGImage = image.cgImage!
        let width = inputCGImage.width
        let height = inputCGImage.height
        
        let size = height * width
        
        let pixels = UnsafeMutablePointer<Int>.allocate(capacity: size)
        var processedImage: UIImage? = nil
        
        if size >= MIN_PIXELS {
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            
            let context: CGContext = CGContext(data: pixels,
                                               width: width,
                                               height: height,
                                               bitsPerComponent: BITS_PER_COMPONENT,
                                               bytesPerRow: BYTES_PER_PIXEL * width,
                                               space: colorSpace,
                                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)!
            
            context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            let success = hide(string: text, inPixels: pixels, withSize: size, error: &error)
            
            if (success) {
                let newCGImage: CGImage = context.makeImage()!
                processedImage = UIImage(cgImage: newCGImage)
            }
        } else {
            error = NSError(domain: "ISStegoErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey : "Image is too small"])
        }
        
        pixels.deallocate()
        
        return processedImage
    }
    
    private func hide(string: String, inPixels pixels: UnsafeMutablePointer<Int>, withSize size:Int, error: inout NSError?) -> Bool {
        var success = false
        
        let messageToHide = messageToHide(string: string)
        
        var dataLength = messageToHide.length
        
        if dataLength <= INT_MAX
                && dataLength * BITS_PER_COMPONENT < size - INFO_LENGTH {
            reset()
            
            let data: Data = Data(bytes: &dataLength, count: BYTES_OF_LENGTH)
            
            let lengthDataInfo: String = String(data: data, encoding: .ascii)!
            
            var pixelPosition: Int = 0
            
            self.currentDataToHide = lengthDataInfo
            
            while (pixelPosition < INFO_LENGTH) {
                pixels[pixelPosition] = new(pixel: pixels[pixelPosition])
                pixelPosition += 1
            }
            
            reset()
            
            let pixelsToHide: Int = messageToHide.length * BITS_PER_COMPONENT;
            
            self.currentDataToHide = messageToHide
            
            let ratio: Int = (size - pixelPosition) / pixelsToHide
            
            let salt: Int = ratio;
            
            while (pixelPosition <= size) {
                pixels[pixelPosition] = new(pixel: pixels[pixelPosition])
                pixelPosition += salt
            }
            
            success = true
        } else {
            error = NSError(domain: "ISStegoErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey : "The data is too big"])
        }
        
        return success;
    }
    
    private func reset() {
        currentShift = INITIAL_SHIFT
        currentCharacter = 0
    }
    
    private func new(pixel: Int) -> Int {
        let color: Int = new(color: pixel)
        step += 1
        return color
    }

    private func new(color: Int) -> Int {
        if (currentDataToHide!.length > currentCharacter!) {
            let currData = currentDataToHide! as NSString
            let asciiCode = currData.character(at: currentCharacter!)
            
            let shiftedBits = asciiCode >> currentShift!
            
            if (currentShift == 0) {
                currentShift = INITIAL_SHIFT
                currentCharacter! += 1
            } else {
                currentShift! -= 1
            }
            
            return new(pixel: color, shiftedBits: Int(shiftedBits), shift: colorToStep(step: step))
        }
        
        return color
    }
    
    private func new(pixel: Int, shiftedBits: Int, shift: Int) -> Int {
        let bit = (shiftedBits & 1) << 8 * shift
        let colorAndNot = (pixel & ~(1 << 8 * shift))
        return colorAndNot | bit
    }
    
    private func messageToHide(string: String) -> String {
        let base64 = base64FromString(string)
        return DATA_PREFIX + base64 + DATA_SUFFIX
    }
    
    private func base64FromString(_ string: String) -> String {
        let data = string.data(using: .utf8)
        return (data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!
    }
}
