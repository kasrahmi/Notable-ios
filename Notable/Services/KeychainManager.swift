import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    private func keychainQuery(for key: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: "com.example.notable",
         kSecAttrAccount as String: key]
    }

    func set(_ value: Data, for key: String) {
        var query = keychainQuery(for: key)
        SecItemDelete(query as CFDictionary)
        query[kSecValueData as String] = value
        SecItemAdd(query as CFDictionary, nil)
    }

    func get(_ key: String) -> Data? {
        var query = keychainQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    func delete(_ key: String) {
        let query = keychainQuery(for: key)
        SecItemDelete(query as CFDictionary)
    }
}

enum TokenKeys {
    static let access = "access_token"
    static let refresh = "refresh_token"
    static let expiry = "token_expiry"
}


