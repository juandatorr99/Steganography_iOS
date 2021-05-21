//
//  ShowViewController.swift
//  Steganography
//
//  Created by Juan David Torres  on 12/05/21.
//

import UIKit

class ShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var buttonChooseImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonChooseImage.clipsToBounds = true
        buttonChooseImage.layer.cornerRadius = 10
    }
    
    func presentPicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[.originalImage] as! UIImage
        self.imageView.image = image
        
        showMessage()
    }
    
    @IBAction func clickChooseImage(_ sender: Any) {
        presentPicker(with: .photoLibrary)
    }
    
    private func showMessage() {
        var error: NSError?
        let text = Decoder().decodeStegoImage(image: imageView.image!, error: &error)
        if error != nil {
            labelMessage.text = error!.description
        } else {
            labelMessage.text = text
        }
    }
}
