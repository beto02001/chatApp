//
//  MessagesViewController.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import UIKit

class ChatsViewController: UIViewController {
    
    var messageViewModel = MessageViewModel()
    var autheticationViewModel: AuthenticationViewModel?
    var coordinator: Coordinator?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tableMessages: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        autheticationViewModel?.getCurrentUser()
        messageViewModel.user = autheticationViewModel?.user ?? User()
        Task {
            await messageViewModel.setProfile(profile: Profile(user: autheticationViewModel?.user ?? User()))
            await messageViewModel.getChatsByUserID()
        }
        if #available(iOS 16.0, *) {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.rightBarButtonItem?.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setDelegates() {
        messageViewModel.delegate = self
        tableMessages.delegate = self
        tableMessages.dataSource = self
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let message = tfMessage.text ?? ""
        Task {
            await messageViewModel.findProfileOtherUser(email: message, isForNewChat: true)
        }
        tfMessage.text = ""
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = keyboardHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func logoutSession() {
        do {
            try autheticationViewModel?.logout()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error")
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        logoutSession()
    }
    
    @IBAction func goToProfile(_ sender: Any) {
        coordinator?.navigateToProfileView(navigationController: navigationController, viewModel: messageViewModel)
    }
}

extension ChatsViewController: ChatsViewModelDelegate {
    func didReceiveMessages(_ messages: [Messages]) {
        //print(messages)
        DispatchQueue.main.async {
            self.tableMessages.reloadData()
        }
    }
    
    func didFailWithError(_ error: String) {
        print(error)
    }
    
    func findedUserID(_ profileUserFind: Profile) {
        print("Usuario encontrado por correo: ", profileUserFind)
        Task {
            await  messageViewModel.setChat(profileUserToSendMessage: profileUserFind)
        }
        didReceiveMessages([])
    }
}


extension ChatsViewController: UITableViewDelegate, UITableViewDataSource   {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageViewModel.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatUser", for: indexPath)
        
        let chat = messageViewModel.chats[indexPath.row]
        
        
        cell.textLabel?.text = chat.emailDestinatario
        cell.detailTextLabel?.text = chat.idDestinatario
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = messageViewModel.chats[indexPath.row]
        print(messageViewModel.chats[indexPath.row])

        self.messageViewModel.profileDestination.idUser = info.idDestinatario
        self.messageViewModel.profileDestination.email = info.emailDestinatario
        coordinator?.navigateToMessagesView(navigationController: navigationController, viewModel: self.messageViewModel, chats: info)
        
    }

}
