//
//  Messages.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation

struct Messages: Identifiable, Codable {
    var id: String
    var text: String
    var username: String
    var idUser: String
    var timestmap: Date
}

struct Chats: Codable {
    var idDestinatario: String?
    var emailDestinatario: String?
    var ultimoMensaje: String?
    var timestamp: String?
    
    init(idDestinatario: String? = nil, emailDestinatario: String? = nil, ultimoMensaje: String? = nil, timestamp: String? = nil) {
        self.idDestinatario = idDestinatario
        self.emailDestinatario = emailDestinatario
        self.ultimoMensaje = ultimoMensaje
        self.timestamp = timestamp
    }
    
    init(from: Profile) {
        self.idDestinatario = from.idUser
        self.emailDestinatario = from.email
        self.ultimoMensaje = ""
        self.timestamp = Date().description
    }
}

struct Profile: Codable {
    var apellido: String?
    var email: String?
    var estado: Bool?
    var imagenPerfil: String?
    var nombre: String?
    var idUser: String?
    
    init(apellido: String? = nil, email: String? = nil, estado: Bool? = true, imagenPerfil: String? = nil, nombre: String? = nil, idUser: String? = nil) {
        self.apellido = apellido
        self.email = email
        self.estado = estado
        self.imagenPerfil = imagenPerfil
        self.nombre = nombre
        self.idUser = idUser
    }
    
    init(user: User) {
        self.apellido = ""
        self.email = user.email
        self.estado = true
        self.imagenPerfil = ""
        self.nombre = ""
        self.idUser = user.idUser
    }
}



