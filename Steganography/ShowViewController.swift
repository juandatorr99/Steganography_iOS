//
//  ShowViewController.swift
//  Steganography
//
//  Created by Juan David Torres  on 12/05/21.
//

import UIKit

class ShowViewController: UIViewController {

    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseImgButton.clipsToBounds = true
        chooseImgButton.layer.cornerRadius = 10
        
        showButton.clipsToBounds = true
        showButton.layer.cornerRadius = 10
    }
    
    @IBAction func didTapShowMessage(_ sender: Any) {
        showMessage(imageToDecode: self.imageView.image!)
    }
    
    @IBAction func didTapChooseImage(_ sender: Any) {
        presentPicker(with: .photoLibrary)
    }
    
    private func showMessage(imageToDecode: UIImage) {
        guard let text = Decoder.decode(image: imageView.image!) else {
            showAlert(message: "Lo sentimos, la imagen seleccionada no contiene un mensaje oculto.", viewController: self)
            return
        }
        
        labelMessage.text = text
    }
    
}

extension ShowViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[.originalImage] as! UIImage
        self.imageView.image = image
    }
    
    private func presentPicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
}
