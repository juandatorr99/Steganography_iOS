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
        encodeMessage()
    }
    
//    func selectFiles() {
//        let types = UTType.types(tag: "png",
//                                 tagClass: UTTagClass.filenameExtension,
//                                 conformingTo: nil)
//        let documentPickerController = UIDocumentPickerViewController(
//            forOpeningContentTypes: types)
//        documentPickerController.delegate = self
//        self.present(documentPickerController, animated: true, completion: nil)
//    }
    
    private func encodeMessage() {
        guard let resultingImage = Encoder.encode(image: imageHide.image!, text: textView.text) else {
            showAlert()
            return
        }
        
        let imageToShare = [resultingImage.pngData()]
        let activityViewController = UIActivityViewController(activityItems: imageToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // iPad support
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.openInIBooks]
        
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
    
    private func showAlert() {
        let alert = UIAlertController(title: "Error", message: "No se pudo ocultar tu mensaje en la seleccionada. Por favor intenta de nuevo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            textView.text = PLACEHOLDER
            textView.textColor = UIColor.lightGray
            buttonHide.isHidden = true
        } else {
            buttonHide.isHidden = false
        }
    }
}

extension HideViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentPicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        imageHide.image = image
        
        textView.isHidden = false
    }
}
