//
//  Coordinator.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import UIKit

protocol Coordinator {
    func navigateToMessagesView(navigationController: UINavigationController?, viewModel: MessageViewModel, chats: Chats)
    func navigateToChatsView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel)
    func navigateToRegisterView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel, segue: UIStoryboardSegue)
    func navigateToProfileView(navigationController: UINavigationController?, viewModel: MessageViewModel)
}


class MainCoordinator: Coordinator {
    func navigateToMessagesView(navigationController: UINavigationController?, viewModel: MessageViewModel, chats: Chats) {
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        guard let controller = storyboard.instantiateViewController(identifier: "MessagesSB") as? MessagesViewController else { return }
        controller.messagesViewModel = viewModel
        controller.coordinator = self
        controller.chats = chats
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func navigateToChatsView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel) {
        let storyboard = UIStoryboard(name: "Chats", bundle: nil)
        guard let controller = storyboard.instantiateViewController(identifier: "ChatsSB") as? ChatsViewController else { return }
        controller.autheticationViewModel = viewModel
        controller.coordinator = self
        navigationController?.pushViewController(controller, animated: true)
    }

    func navigateToRegisterView(navigationController: UINavigationController?, viewModel: AuthenticationViewModel, segue: UIStoryboardSegue) {
        let viewController = segue.destination as! RegisterViewController
        viewController.autheticationViewModel = viewModel
    }
    
    func navigateToProfileView(navigationController: UINavigationController?, viewModel: MessageViewModel) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let controller = storyboard.instantiateViewController(identifier: "ProfileSB") as? ProfileViewController else { return }
        controller.messageVieModel = viewModel
        controller.coordinator = self
        DispatchQueue.main.async {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

