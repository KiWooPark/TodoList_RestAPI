//
//  TodoError.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/01.
//

import Foundation

enum TodoError: Error {
    case getTodosError
    case getTodoError
    case addTodoError
    case updateTodoError
    case deleteTodoError
    
    case jsonSerializationError
    
    case urlError
    
    case statusCodeError
    
    case decodeError
    
    case imageNil
    case uploadImageError
}
