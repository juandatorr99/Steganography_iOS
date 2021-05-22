//
//  ImageSaver.swift
//  Steganography
//
//  Created by Sandra Román on 20/05/21.
//

import UIKit

class ImageSaver: NSObject {
    /* if we need to flip the image:
     var flippedImage = image

    if let cg = image.cgImage {
        flippedImage = UIImage(cgImage: cg, scale: 1.0, orientation: .downMirrored)
    }*/
    static func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }

        
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
