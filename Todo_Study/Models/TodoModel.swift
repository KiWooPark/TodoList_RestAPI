//
//  TodoModel.swift
//  Todo_Study
//
//  Created by PKW on 2023/01/31.
//

import Foundation
import UIKit

// MARK: Model
struct TodoModel: Codable {
    var id: Int?
    var imageURl: String?
    var title: String?
    var content: String?
    let modifiedDate: String?
    var colorCount: Int?
    var progressCount: Int?
    var createdDate: String?
    
    // 서버 X
    var isEdited: Bool? = false
    var image: UIImage?

    enum CodingKeys: String, CodingKey {
        case id
        case imageURl
        case title
        case content
        case modifiedDate
        case colorCount
        case progressCount
        case createdDate
    }
}


//    init(id: Int? = nil, imageURl: String? = nil, title: String? = nil, content: String? = nil, modifiedDate: String? = nil, colorCount: Int? = nil, progressCount: Int? = nil, createdDate: String? = nil, isEdited: Bool? = false, image: UIImage? = nil) {
//        self.id = id
//        self.imageURl = imageURl
//        self.title = title
//        self.content = content
//        self.modifiedDate = modifiedDate
//        self.colorCount = colorCount
//        self.progressCount = progressCount
//        self.createdDate = createdDate
//        self.isEdited = isEdited
//        self.image = image
//    }





