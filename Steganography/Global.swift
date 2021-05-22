//
//  Global.swift
//  Steganography
//
//  Created by Sandra Román on 22/05/21.
//

import UIKit

let ColorSpace = CGColorSpaceCreateDeviceRGB()
let BytesPerPixel = 4
let BitsPerComponent = 8
let BitmapInfo = RGBA32.bitmapInfo

func showAlert(message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}
