//
//  MessagePresentation.swift
//  note_app
//
//  Created by Bogdan on 15.03.2025.
//

import Foundation

struct MessagePresentation {
    let id: UUID
    let date: String
    let message: String
    let imagesURL: [URL]?
    
    init(messageData: MessageData) {
        self.id = messageData.id
        self.date = "Date: " + CustomDateFormatters.recordDoneTimeDateFormatter.string(from: messageData.date)
        self.message = "Note: " + messageData.message
        if let imageNames = messageData.imageNames {
            self.imagesURL = imageNames.compactMap { ImageSaveService.makeImageUrl(fromImageName: $0) }
        } else {
            self.imagesURL = nil
        }
    }
}
