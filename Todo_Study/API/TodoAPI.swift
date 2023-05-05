//
//  TodoAPI.swift
//  Todo_Study
//
//  Created by PKW on 2023/01/31.
//

import Foundation

enum TodosAPI {
    
    static let version = "v1"
    
    static let baseUrl = "https://port-0-container-1ih8d2gld1q6ldo.gksl2.cloudtype.app/api/" + version
    
    // MARK: CREATE
    static func addTodo(todo: TodoModel?, completion: @escaping (Result<TodoModel,TodoError>) -> ()) {
        
        // 1
        let urlString = baseUrl + "/todo"
        
        guard let url = URL(string: urlString) else {
            print("url 에러")
            return completion(.failure(.urlError))
        }
        
        // 2
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        // 3
        do {
            let jsonData = try JSONEncoder().encode(todo)
            urlRequest.httpBody = jsonData
        } catch {
            print("파라미터 변환 에러")
            return completion(.failure(.jsonSerializationError))
        }
        
        // 4
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                completion(.failure(.addTodoError))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.statusCodeError))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.statusCodeError))
            }
            
            // 5
            if let jsonData = data {
                do {
                    let responseData = try JSONDecoder().decode(TodoModel.self, from: jsonData)
                    // 7
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }.resume() // 6
    }
    
    // MARK: READ
    static func fetchTodos(completion: @escaping (Result<[TodoModel],TodoError>) -> ()) {
        
        // 1
        let urlString = baseUrl + "/todos"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlError))
        }
        
        // 2
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        // 3
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                completion(.failure(.getTodoError))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.statusCodeError))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.statusCodeError))
            }
            
            // 5
            if let jsonData = data {
                do {
                    let responseData = try JSONDecoder().decode([TodoModel].self, from: jsonData)
                    
                    // 6
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
            
        }.resume() // 4
    }
    
    // MARK: UPDATE
    static func updateTodo(id: Int, updateData: TodoModel?, completion: @escaping (Result<Int?,TodoError>) -> ()) {
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            print("url 에러")
            return completion(.failure(.urlError))
        }
    
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(updateData)
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(.jsonSerializationError))
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let error = error {
                completion(.failure(.updateTodoError))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.statusCodeError))
            }        
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.statusCodeError))
            }
            
            if let jsonData = data {
                do {
                    let responseData = try JSONDecoder().decode(Int.self, from: jsonData)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }.resume()
    }
    
    // MARK: DELETE
    static func deleteTodo(id: Int, completion: @escaping (Result<Int?,TodoError>) -> ()) {
        
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlError))
        }
    
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let _ = error {
                completion(.failure(.updateTodoError))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.statusCodeError))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.statusCodeError))
            }
            
            if let jsonData = data {
                do {
                    let responseData = try JSONDecoder().decode(Int.self, from: jsonData)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }.resume()
    }
    
    // SEARCH
    static func searchTodo(id: Int, completion: @escaping (Result<TodoModel,TodoError>) -> ()) {
        let urlString = baseUrl + "/todo" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(.urlError))
        }
    
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "Get"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            if let _ = error {
                completion(.failure(.updateTodoError))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.statusCodeError))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.statusCodeError))
            }
            
            if let jsonData = data {
                do {
                    let responseData = try JSONDecoder().decode(TodoModel.self, from: jsonData)
                    completion(.success(responseData))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }.resume()
    }
}



