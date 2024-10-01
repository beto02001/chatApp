//
//  RegisterViewController.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var tfRegisterUser: UITextField!
    @IBOutlet weak var tfRegisterPassword: UITextField!
    
    var autheticationViewModel: AuthenticationViewModel?
    var coordinator: MainCoordinator = MainCoordinator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autheticationViewModel?.delegateCreateUser = self
    }
    
    
    @IBAction func createUser(_ sender: Any) {
        regiterUser()
    }
    
    func regiterUser() {
        autheticationViewModel?.createNewUser(email: tfRegisterUser.text ?? "", password: tfRegisterPassword.text ?? "")
    }
    
}

extension RegisterViewController: createAndSignInProtocol {
    func errorCreate(messageError: String, titleError: ErrorTitle) {
        autheticationViewModel?.showAlertErrorMessage(viewController: self, titleError: titleError, messageError: messageError)
    }
    
    func succesfulCreate() {
        autheticationViewModel?.showAlertErrorMessage(viewController: self, titleError: .exito, messageError: "el usuario")
    }
}
