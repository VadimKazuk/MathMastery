import Foundation

let KeychainServiceID = "Authentication"
let KeychainAccountEmail = "Email"
let KeychainAccountPassword = "Password"

protocol KeychainService {
    func save(service: String, account: String, data: String)
    func load(service: String, account: String) -> String?
    func delete(service: String, account: String)
}

class KeychainManager: KeychainService {
    func save(service: String, account: String, data: String) {
        if let data = data.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecValueData: data
            ] as CFDictionary

            SecItemDelete(query)
            SecItemAdd(query, nil)
        }
    }

    func load(service: String, account: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data,
               let retrievedString = String(data: retrievedData, encoding: .utf8) {
                return retrievedString
            }
        }

        return nil
    }

    func delete(service: String, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary

        let _ = SecItemDelete(query)
    }
}

