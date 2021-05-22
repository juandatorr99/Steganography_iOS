//
//  ViewController.swift
//  Steganography
//
//  Created by Juan David Torres  on 29/04/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class HideViewController: UIViewController, UIDocumentPickerDelegate {
    private let PLACEHOLDER = "Ingresa el mensaje"
    
    @IBOutlet weak var buttonChoose: UIButton!
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var imageHide: UIImageView!
    @IBOutlet weak var buttonHide: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.text = PLACEHOLDER
        textView.textColor = UIColor.lightGray
        
        buttonChoose.clipsToBounds = true
        buttonChoose.layer.cornerRadius = 10
        
        buttonCamera.clipsToBounds = true
        buttonCamera.layer.cornerRadius = 10
        
        buttonHide.clipsToBounds = true
        buttonHide.layer.cornerRadius = 10
        
        self.setupHideKeyboardOnTap()
        
        buttonHide.isHidden = true
        textView.isHidden = true
        
        textView!.layer.borderWidth = 1
        textView!.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10;
    }
    
    @IBAction func clickButtonChoose(_ sender: Any) {
        presentPicker(with: .photoLibrary)
    }
    
    @IBAction func clickButtonCamera(_ sender: Any) {
        presentPicker(with: .camera)
    }
    
    @IBAction func clickButtonHide(_ sender: Any) {
//        let binaryData = Data(textView.text.utf8)
//        let stringOf01 = binaryData.reduce("") { (acc, byte) -> String in
//            var transformed = String(byte, radix: 2)
//            while transformed.count < 8 {
//                transformed = "0" + transformed
//            }
//            return acc + transformed
//        }
        
        encodeMessage()
    }
    
    func selectFiles() {
        let types = UTType.types(tag: "png",
                                 tagClass: UTTagClass.filenameExtension,
                                 conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
                forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    private func presentPicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
   private func encodeMessage(){
        let resultingImage = Encoder().encode(image: imageHide.image!, text: textView.text)!
        
        let imageToShare = [ resultingImage.pngData() ]
    let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    private func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

extension HideViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Ingresa el mensaje"
            textView.textColor = UIColor.lightGray
            buttonHide.isHidden = true
        } else {
            buttonHide.isHidden = false
        }
    }
}

extension HideViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        imageHide.image = image
        
        textView.isHidden = false
    }
}

extension CGImage {
    private func pixel(x: Int, y: Int) -> (r: Int, g: Int, b: Int)? {
        guard let pixelData = dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else { return nil }
        
        let pixelInfo = ((width  * y) + x ) * 4
        
        let red = Int(data[pixelInfo])
        let green = Int(data[(pixelInfo + 1)])
        let blue = Int(data[pixelInfo + 2])
        
        return (red, green, blue)
    }
}
