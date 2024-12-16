//
//  AuthenticationModel.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation

struct User {
    let email: String
    let idUser: String
    
    init(email: String, idUser: String) {
        self.email = email
        self.idUser = idUser
    }
    
    init() {
        email = "usuarioNoDisponible"
        idUser = ""
    }

}
