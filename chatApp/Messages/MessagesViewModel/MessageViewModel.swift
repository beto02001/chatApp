//
//  MessageViewModel.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import FirebaseFirestore

protocol MessageViewModelDelegate: AnyObject {
    func didReceiveMessages(_ messages: [Messages])
    func didFailWithError(_ error: String)
    func didUpdateLastMessageId(_ lastId: String)
}

final class MessageViewModel {
    
    weak var delegate: MessageViewModelDelegate?
    
    var messages: [Messages] = []
    private var lastId: String = ""
    
    private let db = Firestore.firestore()
    
    init() {
        getMessages()
    }
    
    func getMessages() {
        db.collection("messages").addSnapshotListener { [weak self] QuerySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didFailWithError("Error al obtener mensajes: \(error.localizedDescription)")
                return
            }
            
            guard let documents = QuerySnapshot?.documents else { return }
            
            self.messages = documents.compactMap({ document -> Messages? in
                do {
                    return try document.data(as: Messages.self)
                } catch {
                    print("Error al decodificar el mensaje", error.localizedDescription)
                    return nil
                }
            })
            
            self.messages.sort { $0.timestmap < $1.timestmap }
            
            if let id = self.messages.last?.id {
                self.lastId = id
                self.delegate?.didUpdateLastMessageId(self.lastId)
            }
            
            self.delegate?.didReceiveMessages(self.messages)
        }
    }
    
    func sendMessage(text: String, user: User) {
        do {
            let newMessage = Messages(id: "\(UUID())", text: text, username: user.email, idUser: user.idUser, timestmap: Date())
            try db.collection("messages").document().setData(from: newMessage)
        } catch let error as NSError {
            delegate?.didFailWithError("Error al enviar mensaje: \(error.localizedDescription)")
        }
    }
}
