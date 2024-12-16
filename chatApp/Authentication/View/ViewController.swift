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
        static let registerUser = "registerUser"
    }

    var autheticationViewModel: AuthenticationViewModel = AuthenticationViewModel()
    var coordinator: Coordinator = MainCoordinator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autheticationViewModel.delegate = self
        autheticationViewModel.isUserLogged()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func login(_ sender: UIButton) {
        loginUser()
    }
    
    func loginUser() {
        autheticationViewModel.loginUser(email: tfUser.text ?? "", password: tfPassword.text ?? "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueName.registerUser {
            coordinator.navigateToRegisterView(navigationController: self.navigationController, viewModel: autheticationViewModel, segue: segue)
        }
    }
    
}

extension ViewController: createAndSignInProtocol {
    
    func errorCreate(messageError: String, titleError: ErrorTitle) {
        autheticationViewModel.showAlertErrorMessage(viewController: self, titleError: titleError, messageError: messageError)
    }
    
    func succesfulCreate() {
        coordinator.navigateToChatsView(navigationController: self.navigationController, viewModel: self.autheticationViewModel)
    }
}
