//
//  ShowViewController.swift
//  Steganography
//
//  Created by Juan David Torres  on 12/05/21.
//

import UIKit

class ShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var buttonChooseImage: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonChooseImage.clipsToBounds = true
        buttonChooseImage.layer.cornerRadius = 10
        
        showButton.clipsToBounds = true
        showButton.layer.cornerRadius = 10
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
    }
    
    @IBAction func showButtonClick(_ sender: Any) {
        showMessage(imageToDecode: self.imageView.image!)
    }
    @IBAction func clickChooseImage(_ sender: Any) {
        presentPicker(with: .photoLibrary)
    }
    
    private func showMessage(imageToDecode:UIImage) {
        let text = Decoder().decode(image: imageView.image!)
        labelMessage.text = text
    }
}
