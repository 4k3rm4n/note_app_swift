//
//  ImageSaveService.swift
//  note_app
//
//  Created by Bogdan on 18.03.2025.
//

import Foundation
import CryptoKit
import UIKit

protocol ImageSaveServiceProtocol {
    func saveImages(with urls: [URL]) -> [ImagesData]

}

struct ImageSaveService: ImageSaveServiceProtocol {
    func saveImages(with urls: [URL]) -> [ImagesData] {
        urls.compactMap { url in
            let (original, thumbnail) = getImageURL(with: url)
            guard let originalName = original?.lastPathComponent, let thumbnailName = thumbnail?.lastPathComponent else { return ImagesData() }
            return ImagesData(originalImagePath: originalName, thumbnailImagePath: thumbnailName)
        }
    }
    
    func deleteImage(with url: URL) {
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            } else {
                print("image doesnt exist")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    static func makeImageUrl(fromImageName imageName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil}
        
        return documentDirectory.appendingPathComponent(imageName)
    }
    
    private func getImageURL(with url: URL) -> (original: URL?, thumbnail: URL?) {
        let fileManager = FileManager.default
        let image = UIImage(contentsOfFile: url.path)
        guard let tmpFileData = image?.jpegData(compressionQuality: 1) else { return (nil, nil) }
        
        guard let documentDirectory = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return (nil, nil) }
        
        guard let directoryContents = try? fileManager.contentsOfDirectory(
            at: documentDirectory,
            includingPropertiesForKeys: nil
        ) else { return (nil, nil) }
        
        let fileUrl: URL? = directoryContents.filter { fileUrl in
            fileSize(atPath: fileUrl.path) == fileSize(atPath: url.path)
        }.compactMap { fileUrl in
            let image = UIImage(contentsOfFile: fileUrl.path)
            guard let documentFileData = image?.jpegData(compressionQuality: 1) else { return nil }
            return sha256String(from: documentFileData) == sha256String(from: tmpFileData) ? fileUrl : nil
        }.first
        
        if let fileUrl = fileUrl {
            let originalImageNameComponents = fileUrl.lastPathComponent.components(separatedBy: ".")
            let thumbnailImageName = originalImageNameComponents[0] + Constants.imageThumbnailSuffix + "." + originalImageNameComponents.last!
            let thumbnailImageURL = documentDirectory.appendingPathComponent(thumbnailImageName)
            
            return (fileUrl, thumbnailImageURL)
        }
        
        let destinationFileName = url.lastPathComponent
        
        let destinationURL = documentDirectory.appendingPathComponent(destinationFileName)
        
        guard let originalImageURL = copyImage(at: url, to: destinationURL) else { return (nil, nil) }
        
        return (originalImageURL, generateImageThumbnail(from: originalImageURL, thumbnailSize: CGSize(width: 100, height: 100)))
    }
    
    private func copyImage(at url: URL, to destinationURL: URL) -> URL? {
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(atPath: url.path, toPath: destinationURL.path)
            return destinationURL
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func generateImageThumbnail(from imageURL: URL, thumbnailSize: CGSize) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ), let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
        let thumbnailImage = image.thumbnailOfSize(thumbnailSize)
        let imageNameComponents = imageURL.lastPathComponent.components(separatedBy: ".")
        let imageName = imageNameComponents[0] + Constants.imageThumbnailSuffix + "." + imageNameComponents.last!

        guard let thumbnailImageData = thumbnailImage?.jpegData(compressionQuality: 1) else { return nil }
        let thumbnailImageURL = documentDirectory.appendingPathComponent("\(imageName)")
        do {
            try thumbnailImageData.write(to: thumbnailImageURL)
            return thumbnailImageURL
        } catch {
            print("Error can not write thumbnail image to file")
            return nil
        }
    }
    
    func fileSize(atPath path: String) -> Int64? {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            if let size = attributes[.size] as? Int64 {
                return size
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
        }
        return nil
    }
    
    func sha256String(from data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined() // Convert to hex string
    }
}


private extension ImageSaveService {
    enum Constants {
        static let imageThumbnailSuffix = "_thumbnail"
    }
}
