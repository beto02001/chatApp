//
//  ViewController.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tfUser: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    enum segueName {
        static let login = "mainToLogin"
        static let register = "mainToRegister"
    }

    var autheticationViewModel: AuthenticationViewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autheticationViewModel.delegate = self
    }
    
    @IBAction func login(_ sender: UIButton) {
        loginUser()
    }
    
    func loginUser() {
        autheticationViewModel.loginUser(email: tfUser.text ?? "", password: tfPassword.text ?? "")
    }
    
}

extension ViewController: createAndSignInProtocol {
    
    func errorCreate(messageError: String, titleError: ErrorTitle) {
        autheticationViewModel.showAlertErrorMessage(viewController: self, titleError: titleError, messageError: messageError)
    }
    
    func succesfulCreate() {
        autheticationViewModel.showAlertErrorMessage(viewController: self, titleError: .siSePudo, messageError: "Si se pudo")
    }
}
