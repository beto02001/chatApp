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

