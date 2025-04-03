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
    let imagesData: [ImagesData]?

    init(id: UUID = UUID(), date: Date = Date(), message: String, imagesData: [ImagesData]? = nil) {
        self.id = id
        self.date = date
        self.message = message
        self.imagesData = imagesData
    }
}
