import Foundation
import Security

class Config {
    private let defaults = UserDefaults.standard
    // NOTE: Token is stored in Keychain (not UserDefaults).
    // This key is used as the Keychain "account" identifier.
    private let tokenKey = "github_token"
    private let usernameKey = "github_username"
    private let reposKey = "monitored_repositories"
    
    private var keychainService: String {
        // Stable per-app identifier; falls back to a constant if unavailable.
        Bundle.main.bundleIdentifier ?? "LGTM"
    }
    
    func hasToken() -> Bool {
        return getToken() != nil
    }
    
    func getToken() -> String? {
        keychainRead(account: tokenKey)
    }
    
    func saveToken(_ token: String) {
        _ = keychainUpsert(account: tokenKey, value: token)
    }
    
    func deleteToken() {
        _ = keychainDelete(account: tokenKey)
        defaults.removeObject(forKey: usernameKey)
        defaults.removeObject(forKey: reposKey)
    }
    
    func getUsername() -> String? {
        return defaults.string(forKey: usernameKey)
    }
    
    func saveUsername(_ username: String) {
        defaults.set(username, forKey: usernameKey)
    }
    
    func getRepos() -> [String] {
        return defaults.stringArray(forKey: reposKey) ?? []
    }
    
    func saveRepos(_ repos: [String]) {
        let filtered = repos.filter { !$0.isEmpty }
        defaults.set(filtered, forKey: reposKey)
    }
}

// MARK: - Keychain helpers
extension Config {
    private func baseKeychainQuery(account: String) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: account
        ]
    }
    
    private func keychainRead(account: String) -> String? {
        var query = baseKeychainQuery(account: account)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = true
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    private func keychainUpsert(account: String, value: String) -> OSStatus {
        let data = Data(value.utf8)
        
        // Try update first
        let query = baseKeychainQuery(account: account)
        let attributesToUpdate: [CFString: Any] = [
            kSecValueData: data
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if updateStatus == errSecSuccess {
            return updateStatus
        }
        
        // If not found, add
        if updateStatus == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData] = data
            // Avoid “ask password” prompts: no access control / no user presence; just set accessibility.
            addQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
            return SecItemAdd(addQuery as CFDictionary, nil)
        }
        
        return updateStatus
    }
    
    @discardableResult
    private func keychainDelete(account: String) -> OSStatus {
        let query = baseKeychainQuery(account: account)
        return SecItemDelete(query as CFDictionary)
    }
}
