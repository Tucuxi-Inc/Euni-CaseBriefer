import Foundation
import Security

enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unhandledError(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        case .invalidData:
            return "Invalid data provided"
        case .unhandledError(let status):
            return "Keychain error (status: \(status))"
        }
    }
}

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    func saveAPIKey(_ key: String, forService service: String) throws {
        guard !key.isEmpty else {
            print("Error: Attempting to save empty API key")
            throw KeychainError.invalidData
        }
        
        // Remove "Token " prefix if it exists
        let cleanKey = key.replacingOccurrences(of: "Token ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let keyData = cleanKey.data(using: .utf8) else {
            print("Error: Failed to convert key to data")
            throw KeychainError.invalidData
        }
        
        print("Debug - Saving key for service: \(service)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: keyData
        ]
        
        // First try to delete any existing key
        let deleteStatus = SecItemDelete(query as CFDictionary)
        print("Debug - Delete status: \(deleteStatus)")
        
        // Then add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Debug - Save failed with status: \(status)")
            throw KeychainError.unhandledError(status: status)
        }
        print("Debug - Key saved successfully")
    }
    
    func getAPIKey(forService service: String) throws -> String {
        print("Debug - Retrieving key for service: \(service)")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Debug - Retrieval status: \(status)")
        
        guard status == errSecSuccess else {
            print("Debug - Failed to retrieve key with status: \(status)")
            throw KeychainError.itemNotFound
        }
        
        guard let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            print("Debug - Failed to convert retrieved data to string")
            throw KeychainError.itemNotFound
        }
        
        print("Debug - Key retrieved successfully")
        return key
    }
} 