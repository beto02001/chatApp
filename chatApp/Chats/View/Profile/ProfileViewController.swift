//
//  ProfileViewController.swift
//  chatApp
//
//  Created by Luis Humberto Martinez Echegaray on 10/12/24.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    
    var coordinator: Coordinator?
    var messageVieModel: MessageViewModel?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        setViewDecorations()
        setViewData()
    }
    
    func setButton() {
        buttonCamera.setTitle("", for: .normal)
        buttonCamera.setTitle("", for: .highlighted)
    }
    
    func setViewDecorations() {
        imageProfile.layer.cornerCurve = CALayerCornerCurve(rawValue: "25")
        imageProfile.layer.cornerRadius = imageProfile.frame.width / 2
    }
    
    func setViewData() {
        let profile = messageVieModel?.profile ?? Profile()
        let name = profile.nombre ?? "*"
        let lastName = profile.apellido ?? "-"
        let email = profile.email ?? "--@--.--"
        
        self.name.text = name + " " + lastName
        self.email.text = email
        tfName.text = name
        tfLastName.text = lastName
        
        guard let imagenPerfil = profile.imagenPerfil else { return }
        let imageData = Data(base64Encoded: imagenPerfil)
        let image = UIImage(data: imageData ?? Data())
        imageProfile.image = image
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageProfile.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openGallery(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func backToChat() async {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveChages(_ sender: Any) {
        let imageProfile = imageProfile.image?.jpegData(compressionQuality: 0.1)?.base64EncodedString()
        let profile = Profile(apellido: tfLastName.text, email: messageVieModel?.profile.email, estado: true, imagenPerfil: imageProfile, nombre: tfName.text, idUser: messageVieModel?.profile.idUser)
        Task {
            await messageVieModel?.updateProfile(profile: profile)
            await backToChat()
        }
    }
}
