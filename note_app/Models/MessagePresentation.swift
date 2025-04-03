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
    let imagesData: [ImagesDataPresentation]?
    
    init(messageData: MessageData) {
        self.id = messageData.id
        self.date = "Date: " + CustomDateFormatters.recordDoneTimeDateFormatter.string(from: messageData.date)
        self.message = "Note: " + messageData.message
        if let imagesData = messageData.imagesData {
            self.imagesData = imagesData.compactMap { imageData in
                guard let originalImageURL = ImageSaveService.makeImageUrl(fromImageName: imageData.originalImagePath), let thumbnailImageURL = ImageSaveService.makeImageUrl(fromImageName: imageData.thumbnailImagePath) else { return nil }
               return ImagesDataPresentation(originalImageURL: originalImageURL, thumbnailImageURL: thumbnailImageURL)
            }
        } else {
            self.imagesData = nil
        }
    }
}
