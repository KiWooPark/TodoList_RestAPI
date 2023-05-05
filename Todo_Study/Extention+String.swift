//
//  Extention+String.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/23.
//

import Foundation

extension String {
    // "2023/03/20 16:22",
    func stringToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(identifier: "KST")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
