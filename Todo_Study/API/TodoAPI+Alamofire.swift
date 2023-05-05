//
//  TodoAPI+Alamofire.swift
//  Todo_Study
//
//  Created by PKW on 2023/04/12.
//

import Foundation
import Alamofire

extension TodosAPI {
    
    // MARK: [CREATE] ----------
    static func addTodoWithAlamofire(data: [String: Any], completion: @escaping (TodoModel) -> ()) {
        
        let urlString = baseUrl + "/todo"
  
        AF.request(urlString,
                   method: .post,
                   parameters: data,
                   encoding: JSONEncoding.default,
                   headers: ["Accept":"application/json", "Content-Type":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: TodoModel.self) { response in
            switch response.result {
            case .success(let todo):
                completion(todo)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [READ] ----------
    static func fetchTodosWithAlamofire(completion: @escaping ([TodoModel]) -> ()) {
       
        let urlString = baseUrl + "/todos"
       
        // responseJSON 메소드는 Alamofire 6에서 삭제 예정이므로 responseDecodable을 사용해야 한다.
        AF.request(urlString,
                   method: .get,
                   headers: ["Accept":"application/json", "Content-Type":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [TodoModel].self) { response in
            switch response.result {
            case .success(let todos):
                completion(todos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [UPDATE] ----------
    static func updateTodoWithAlamofire(id: Int, updateData: [String: Any], completion: @escaping (Int) -> ()) {
        
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        AF.request(urlString,
                   method: .put,
                   parameters: updateData,
                   encoding: JSONEncoding.default,
                   headers: ["Accept":"application/json", "Content-Type":"application/json"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Int.self) { response in
                switch response.result {
                case .success(let id):
                    print(id)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    // MARK: [DELETE] ----------
    static func deleteTodoWithAlamofire(id: Int, completion: @escaping (Int) -> ()) {
        
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        AF.request(urlString,
                   method: .delete,
                   headers: ["Accept":"application/json", "Content-Type":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: Int.self) { response in
            switch response.result {
            case .success(let id):
                completion(id)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: [SEARCH] ----------
    static func searchTodoWithAlamofire(id: Int, completion: @escaping (TodoModel) -> ()) {
        
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        AF.request(urlString,
                   method: .get,
                   headers:  ["Accept":"application/json", "Content-Type":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of:TodoModel.self) { response in
            switch response.result {
            case .success(let todo):
                completion(todo)
            case .failure(let error):
                print(error)
            }
        }
    }
}

