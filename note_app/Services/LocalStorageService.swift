//
//  UserDefaultsHelper.swift
//  note_app
//
//  Created by Bogdan on 16.03.2025.
//

import Foundation

struct LocalStorageService {
    private let defaults = UserDefaults.standard
    
    func saveMessage(message: MessageData) throws {
        var storedData = try loadMessages()
        storedData.insert(message, at: .zero)
        
        let encoded = try JSONEncoder().encode(storedData)
        defaults.setValue(encoded, forKey: Constants.messagesKey)
    }
    
    //
    func removeMessage(withID id: UUID) throws {
        var storedData = try loadMessages()
        storedData.removeAll { $0.id == id }
        
        let encoded = try? JSONEncoder().encode(storedData)
        defaults.setValue(encoded, forKey: Constants.messagesKey)
    }
    //
    
    func loadMessages() throws -> [MessageData] {
        guard let savedMessages = defaults.data(forKey: Constants.messagesKey) else { return [] }
        return try JSONDecoder().decode([MessageData].self, from: savedMessages)
    }
}

private extension LocalStorageService {
    enum Constants {
        static let messagesKey = "messages"
    }
}
