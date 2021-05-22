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
    
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.text = PLACEHOLDER
        textView.textColor = UIColor.lightGray
        
        chooseImgButton.clipsToBounds = true
        chooseImgButton.layer.cornerRadius = 10
        
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = 10
        
        hideButton.clipsToBounds = true
        hideButton.layer.cornerRadius = 10
        
        self.setupHideKeyboardOnTap()
        
        hideButton.isHidden = true
        textView.isHidden = true
        
        textView!.layer.borderWidth = 1
        textView!.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10;
    }
    
    @IBAction func didTapChooseImage(_ sender: Any) {
        presentPicker(with: .photoLibrary)
    }
    
    @IBAction func didTapTakePhoto(_ sender: Any) {
        presentPicker(with: .camera)
    }
    
    @IBAction func didTapHideMessage(_ sender: Any) {
        encodeMessage()
    }
    
    private func encodeMessage() {
        guard let resultingImage = Encoder.encode(image: imageView.image!, text: textView.text) else {
            showAlert(message: "No se pudo ocultar tu mensaje en la seleccionada. Por favor intenta de nuevo.", viewController: self)
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
            hideButton.isHidden = true
        } else {
            hideButton.isHidden = false
        }
    }
    
}

extension HideViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        
        textView.isHidden = false
    }
    
    private func presentPicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
}
