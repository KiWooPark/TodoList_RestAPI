//
//  FirebaseAPI.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/23.
//

import Foundation
import UIKit
import FirebaseStorage
import Firebase

enum FirebaseAPI {
    
    static func uploadImage(image: UIImage?, completion: @escaping (Result<String?,TodoError>) -> ()) {
        
        guard let image = image else { return completion(.success(nil)) }
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let firebaseReference = Storage.storage().reference().child("\(UUID().uuidString)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { result in
                switch result {
                case .success(let url):
                    completion(.success(url.absoluteString))
                case .failure(_):
                    completion(.failure(.uploadImageError))
                }
            }
        }
    }
    
    static func deleteImage(url: String?, completion: @escaping (Result<Bool,FirebaseError>) -> ()) {
    
        guard let url = url else { return completion(.success(true)) }
        
        let id = url.components(separatedBy: "/").last?.components(separatedBy: "?")[0] ?? ""

        let firebaseReference = Storage.storage().reference().child(id)
    
        firebaseReference.delete { error in
            if let error = error {
                completion(.failure(.deleteImageError))
            } else {
                completion(.success(true))
            }
        }
    }
}


