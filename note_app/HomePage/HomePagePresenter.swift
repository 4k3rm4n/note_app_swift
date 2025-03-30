//
//  HomePagePresenter.swift
//  note_app
//
//  Created by Bogdan on 15.03.2025.
//

import Foundation
import UIKit

class HomePagePresenter {
    var messagesPresentation: [MessagePresentation] = []
    var onChangedMessageData: (() -> Void)?
    var onErrorCallback: ((String) -> Void)?
    var onMessageRemovedCallback: ((IndexPath) -> Void)?
    var onMessageAddedCallback: (() -> Void)?
    var onChangeSelectedImagesCallback: (() -> Void)?
    let imageSaveService = ImageSaveService()
    var selectedImagesURL: [URL] = []
    var currentImageNames: [String]?
    private let localStorageService = LocalStorageService()
    
    func setup() {
        updateMessages()
    }
    
    func removeMessage(by id: UUID) {
        guard let indexOfItemToRemove = messagesPresentation.firstIndex(where: { $0.id == id }) else { return }
        do {
            try localStorageService.removeMessage(withID: id)
            if let imagesURL = messagesPresentation[indexOfItemToRemove].imagesURL {
                imagesURL.filter{ !isExistSameImageInStorage(by: $0) }
                    .forEach{ imageSaveService.deleteImage(with: $0) }
            }
            updateMessages()
            let indexPath = IndexPath(row: indexOfItemToRemove, section: .zero)
            onMessageRemovedCallback?(indexPath)
        } catch let error {
            onErrorCallback?(error.localizedDescription)
        }
    }
    
    func addNewMessage(message: String) {
        let messageData = MessageData(message: message, imageNames: currentImageNames)
        currentImageNames = nil
        do {
            try localStorageService.saveMessage(message: messageData)
            updateMessages()
            onMessageAddedCallback?()
        } catch let error {
            onErrorCallback?(error.localizedDescription)
        }
    }
    
    func saveSelectedImages() {
        if !selectedImagesURL.isEmpty {
            currentImageNames = imageSaveService.saveImages(with: selectedImagesURL)
        }
        selectedImagesURL.forEach { url in
            removeFileFromTmpDirectory(by: url)
        }
        selectedImagesURL = []
        onChangeSelectedImagesCallback?()
    }
    
    func selectImage(with url: URL) {
        selectedImagesURL.append(url)
        onChangeSelectedImagesCallback?()
    }
    
    func removeSelectedImage(by url: URL) {
        selectedImagesURL = selectedImagesURL.filter { $0 != url }
        removeFileFromTmpDirectory(by: url)
        onChangeSelectedImagesCallback?()
    }
    
    func isSamePictureSelected(by url: URL) -> Bool {
        let newImage = UIImage(contentsOfFile: url.path)
        guard let newImageData = newImage?.jpegData(compressionQuality: 1) else { return false }
        
        let newImageHash = imageSaveService.sha256String(from: newImageData)
        
        if !selectedImagesURL.isEmpty{
            for selectedUrl in selectedImagesURL {
                guard imageSaveService.fileSize(atPath: url.path) == imageSaveService.fileSize(atPath: selectedUrl.path) else { continue }
                guard let existingImageData = UIImage(contentsOfFile: selectedUrl.path)?.jpegData(compressionQuality: 1) else { continue }
                if imageSaveService.sha256String(from: existingImageData) == newImageHash {
                    return true
                }
            }
        }
        return false
    }
    
    func removeFileFromTmpDirectory(by url: URL) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url.path){
            do {
                try fileManager.removeItem(at: url)
            } catch {
               print("error cant delete file from tmp dir")
            }
        }
    }
    
    private func updateMessages() {
        do {
            messagesPresentation = try localStorageService.loadMessages().map(MessagePresentation.init(messageData:))
        } catch let error {
            onErrorCallback?(error.localizedDescription)
        }
    }
    
    private func isExistSameImageInStorage(by url: URL) -> Bool {
        messagesPresentation.compactMap {
            return $0.imagesURL?.contains(url) == true ? $0 : nil
        }
        .count > 1
    }
}
