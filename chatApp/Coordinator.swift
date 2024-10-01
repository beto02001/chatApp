//
//  Coordinator.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import UIKit

protocol Coordinator {
    func navigateToMessagesView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel)
    func navigateToRegisterView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel, segue: UIStoryboardSegue)
}


class MainCoordinator: Coordinator {
    
    func navigateToMessagesView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel) {
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        guard let controller = storyboard.instantiateViewController(identifier: "MessagesSB") as? MessagesViewController else { return }
        controller.autheticationViewModel = viewModel
        navigationController?.pushViewController(controller, animated: true)
    }

    func navigateToRegisterView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel, segue: UIStoryboardSegue) {
        let viewController = segue.destination as! RegisterViewController
        viewController.autheticationViewModel = viewModel
    }
}

