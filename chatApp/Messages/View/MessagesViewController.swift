//
//  MessagesViewController.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import UIKit

class MessagesViewController: UIViewController {
    
    var messageViewModel = MessageViewModel()
    var autheticationViewModel: AuthenticationViewModel?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tableMessages: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageViewModel.delegate = self
        tableMessages.delegate = self
        tableMessages.dataSource = self
        
        if #available(iOS 16.0, *) {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.rightBarButtonItem?.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func sendMessage(_ sender: Any) {
        let message = tfMessage.text ?? ""
        messageViewModel.sendMessage(text: message, user: autheticationViewModel?.user ?? User(email: "", idUser: ""))
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
    
}

extension MessagesViewController: MessageViewModelDelegate {
    func didReceiveMessages(_ messages: [Messages]) {
        print(messages)
        tableMessages.reloadData()
    }
    
    func didFailWithError(_ error: String) {
        print(error)
    }
    
    func didUpdateLastMessageId(_ lastId: String) {
        print(lastId)
    }
}


extension MessagesViewController: UITableViewDelegate, UITableViewDataSource   {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageViewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageUser", for: indexPath)
        
        let message = messageViewModel.messages[indexPath.row]
        
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.username
        
        return cell
    }

}
