//
//  AuthenticationFirebaseDataSource.swift
//  chatApp
//
//  Created by beto on 01/10/24.
//

import Foundation
import FirebaseAuth

final class AuthenticationFirebaseDataSource {
    
    //--------------------------------------------------------------------------
    // MARK: Métodos para ingreso con correo electrónico
    //--------------------------------------------------------------------------
    func getCurrentUser() -> User? {
        guard let email = Auth.auth().currentUser?.email else { return .none }
        guard let uid = Auth.auth().currentUser?.uid else { return .none }
        return .init(email: email, idUser: uid)
    }
    
    func createNewUsers(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if let error = error  {
                print("Error al crear un nuevo usuario: ", error.localizedDescription)
                completionBlock(.failure(error))
                return
            }
            let email = authDataResult?.user.email ?? "no hay email"
            let idUser = authDataResult?.user.uid ?? "no hay id"
            print("Nuevo usuario creado: ", email)
            completionBlock(.success(.init(email: email, idUser: idUser)))
        }
    }
    
    
    func loginUser(email: String, password: String, completionBlock: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                print("No se puedo iniciar sesión: ", error.localizedDescription)
                completionBlock(.failure(error))
            }
            let email = authDataResult?.user.email ?? "no hay email"
            let idUser = authDataResult?.user.uid ?? "no hay id"
            completionBlock(.success(.init(email: email, idUser: idUser)))
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: Métodos salid de sesión
    //--------------------------------------------------------------------------
    func logout() throws {
        try Auth.auth().signOut()
    }
}
