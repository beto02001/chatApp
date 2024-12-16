//
//  MessageViewModel.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import FirebaseFirestore

protocol ChatsViewModelDelegate: AnyObject {
    func didReceiveMessages(_ messages: [Messages])
    func didFailWithError(_ error: String)
    func findedUserID(_ profileUserFind: Profile)
}

final class MessageViewModel {
    
    weak var delegate: ChatsViewModelDelegate?
    weak var delegate2: ChatsViewModelDelegate?
    
    var messages: [Messages] = []
    var messagesFromOtherUser: [Messages] = []
    var messagesMerge: [Messages] = []
    var chats: [Chats] = []
    var user: User
    var profile: Profile = Profile()
    var profileDestination = Profile()
    
    private var lastId: String = ""
    
    private let db = Firestore.firestore()
    
    init(user: User = User()) {
        self.user = user
    }
    
    func getChatsByUserID() async {
        do {
            let querySnapshot = try await db.collection("usuarios/\(user.idUser)/chats").getDocuments()
            self.chats = querySnapshot.documents.compactMap { document in
                try? document.data(as: Chats.self)
            }
            delegate?.didReceiveMessages([])
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}

//MARK: OBTENCIÓN DE PERFIL
extension MessageViewModel {
    
    func findProfileOtherUser(email: String, isForNewChat: Bool = false) async -> String {
        do {
            let documentProfile = try await db.collection("usuarios").whereField("email", isEqualTo: "\(email)").getDocuments()
            let getDoc = documentProfile.documents.first
            guard let profile = try getDoc?.data(as: Profile.self) else { return "No existe" }
            self.profileDestination = profile
            if isForNewChat {
                self.delegate?.findedUserID(profile)
            }
            return profile.idUser ?? "No existe"
            
        } catch {
            print("Usuario no encontrado: \(error)")
            return "No existe"
        }
    }
    
    /// profile: Profile(apellido: Optional(""), email: Optional("beto@gmail.com"), estado: Optional(true), imagenPerfil: Optional(""), nombre: Optional(""))
    func setProfile(profile: Profile) async {
        let docRef = db.collection("usuarios").document(user.idUser)
        do {
            let documentProfile = try await docRef.getDocument()
            if !documentProfile.exists {
                try await docRef.setData(from: profile)
                let profile = try await docRef.getDocument(as: Profile.self)
                print("profile: \(profile)")
            } else {
                self.profile = try await docRef.getDocument(as: Profile.self)
                self.profile
            }
        } catch {
            print(error)
        }
    }
    
    func updateProfile(profile: Profile) async {
        let docRef = db.collection("usuarios").document(user.idUser)
        do {
            try await docRef.setData(from: profile)
            self.profile = profile
            print("Actualización completa")
        } catch {
            print(error)
        }
    }
}

//MARK: OBTENCIÓN DE CHATS
extension MessageViewModel {
    
    func setChat(profileUserToSendMessage profile: Profile) async {
        let docRef = db.collection("usuarios").document(user.idUser).collection("chats").document(profile.idUser ?? "")
        do {
            let documentProfile = try await docRef.getDocument()
            try await docRef.setData(from: Chats(from: profile))
            let profile = try await docRef.getDocument(as: Profile.self)
            print("profile: \(profile)")
        } catch {
            print(error)
        }
        await getChatsByUserID()
    }
}


// MARK: - OBTENCIÓN Y ENVÍO DE MENSAJES
extension MessageViewModel {

    /// Envía un mensaje y lo guarda tanto en la base de datos como en la lista local
    func sendMessage(text: String) async {
        let docRef = db.collection("usuarios")
            .document(user.idUser)
            .collection("chats")
            .document(profileDestination.idUser ?? "idNoDisponible")
            .collection("messages")
            .document()
        
        let newMessage = Messages(
            id: "\(UUID())",
            text: text,
            username: user.email,
            idUser: user.idUser,
            timestmap: Date()
        )
        
        // Añadimos temporalmente el mensaje a la lista local para mostrarlo inmediatamente
        self.messages.append(newMessage)
        self.messages.sort { $0.timestmap < $1.timestmap }
        //self.delegate2?.didReceiveMessages(self.messages)
        
        do {
            // Guardamos el mensaje en Firestore
            try docRef.setData(from: newMessage)
            listenForMessages()
        } catch let error as NSError {
            // Eliminamos el mensaje si ocurre un error al guardar en Firestore
            if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                self.messages.remove(at: index)
            }
            delegate2?.didFailWithError("Error al enviar mensaje: \(error.localizedDescription)")
        }
    }

    /// Escucha los mensajes en tiempo real de ambos usuarios y actualiza la lista local
    func listenForMessages() {
        // Escucha los mensajes enviados por el usuario actual
        db.collection("usuarios")
            .document(user.idUser)
            .collection("chats")
            .document(profileDestination.idUser ?? "idNoDisponible")
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.delegate2?.didFailWithError("Error al obtener mensajes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { document -> Messages? in
                    try? document.data(as: Messages.self)
                }
                self.messages.removeAll()
                self.messages = messages
                //self.messages.sort { $0.timestmap < $1.timestmap }
                self.delegate2?.didReceiveMessages(self.messages)
            }
        
        // Escucha los mensajes enviados por el otro usuario
        db.collection("usuarios")
            .document(profileDestination.idUser ?? "idNoDisponible")
            .collection("chats")
            .document(user.idUser)
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.delegate2?.didFailWithError("Error al obtener mensajes del otro usuario: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                let messagesFromOtherUser = documents.compactMap { document -> Messages? in
                    try? document.data(as: Messages.self)
                }
                
                self.messagesFromOtherUser.removeAll()
                self.messagesFromOtherUser = messagesFromOtherUser
                self.mergeMessages()
            }
    }
    
    /// Combina los mensajes enviados por ambos usuarios y los actualiza en tiempo real
    func mergeMessages() {
        self.messagesMerge = self.messages + self.messagesFromOtherUser
        self.messagesMerge.sort { $0.timestmap < $1.timestmap }
        self.delegate2?.didReceiveMessages(self.messagesMerge)
    }
}
