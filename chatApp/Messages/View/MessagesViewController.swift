//
//  MessagesViewController.swift
//  chatApp
//
//  Created by Luis Humberto Martinez Echegaray on 29/11/24.
//

import UIKit

class MessagesViewController: UIViewController {
    
    
    var messagesViewModel: MessageViewModel?
    var coordinator: Coordinator?
    var chats: Chats?
    
    @IBOutlet weak var tableMessages: UITableView!
    @IBOutlet weak var tfMenssages: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableMessages.refreshControl = refreshControl
        self.navigationItem.prompt = chats?.emailDestinatario
        Task {
            await messagesViewModel?.listenForMessages()
        }
    }
    
    func setDelegates() {
        tableMessages.delegate = self
        tableMessages.dataSource = self
        tableMessages.allowsSelection = false
        
        messagesViewModel?.delegate2 = self
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let mensaje = tfMenssages.text ?? ""
        Task {
            await messagesViewModel?.sendMessage(text: mensaje)
            tfMenssages.text = ""
        }
    }
    
    @objc func refresh() {
        Task {
            await messagesViewModel?.listenForMessages()
        }
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesViewModel?.messagesMerge.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMessage", for: indexPath)
        let message = messagesViewModel?.messagesMerge[indexPath.row]
        cell.textLabel?.text = message?.text
        if message?.username == messagesViewModel?.user.email {
            cell.textLabel?.textAlignment = .right
            cell.backgroundColor = .systemGreen
            cell.textLabel?.textColor = .white
        }
        return cell
    }
}


extension MessagesViewController: ChatsViewModelDelegate {
    func didReceiveMessages(_ messages: [Messages]) {
        print(messages)
        DispatchQueue.main.async {
            self.tableMessages.reloadData()
        }
    }
    
    func didFailWithError(_ error: String) {
        
    }
    
    func findedUserID(_ profileUserFind: Profile) {
        
    }
    
}

