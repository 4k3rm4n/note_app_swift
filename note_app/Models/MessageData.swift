//
//  MessageData.swift
//  note_app
//
//  Created by Bogdan on 16.03.2025.
//

import Foundation

struct MessageData: Codable {
    let id: UUID
    let date: Date
    let message: String
    let imageNames: [String]?

    init(id: UUID = UUID(), date: Date = Date(), message: String, imageNames: [String]? = nil) {
        self.id = id
        self.date = date
        self.message = message
        self.imageNames = imageNames
    }
}
