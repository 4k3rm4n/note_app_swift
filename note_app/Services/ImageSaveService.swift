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
    func saveImages(with urls: [URL]) -> [String]

}

struct ImageSaveService: ImageSaveServiceProtocol {
    func saveImages(with urls: [URL]) -> [String] {
        urls.compactMap{ getImageURL(with: $0)?.lastPathComponent }
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
        //guard let imageName = imageName else { return nil }
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil}
        
        return documentDirectory.appendingPathComponent(imageName)
    }
    
    private func getImageURL(with url: URL) -> URL? {
        let fileManager = FileManager.default
        let image = UIImage(contentsOfFile: url.path)
        guard let tmpFileData = image?.jpegData(compressionQuality: 1) else { return nil }
        
        guard let documentDirectory = try? fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil }
        
        guard let directoryContents = try? fileManager.contentsOfDirectory(
            at: documentDirectory,
            includingPropertiesForKeys: nil
        ) else { return nil }
        
        let fileUrl: URL? = directoryContents.filter { fileUrl in
            fileSize(atPath: fileUrl.path) == fileSize(atPath: url.path)
        }.compactMap { fileUrl in
            let image = UIImage(contentsOfFile: fileUrl.path)
            guard let documentFileData = image?.jpegData(compressionQuality: 1) else { return nil }
            return sha256String(from: documentFileData) == sha256String(from: tmpFileData) ? fileUrl : nil
        }.first
        
        if let fileUrl = fileUrl {
            return fileUrl
        }
        
        let destinationFileName = url.lastPathComponent
        
        let destinationURL = documentDirectory.appendingPathComponent(destinationFileName)
        
        return copyImage(at: url, to: destinationURL)
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
