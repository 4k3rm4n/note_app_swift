//
//  CustomDateFormatters.swift
//  note_app
//
//  Created by Bogdan on 15.03.2025.
//

import Foundation

enum CustomDateFormatters {
    static let recordDoneTimeDateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
}
