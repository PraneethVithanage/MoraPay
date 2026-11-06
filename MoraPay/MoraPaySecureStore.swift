import Foundation
import Security

/// Secure local persistence manager for MoraPay, replacing insecure UserDefaults
/// with encrypted Keychain-backed storage and secure local JSON caching.
public final class MoraPaySecureStore {
    
    public static let shared = MoraPaySecureStore()
    
    private let queue = DispatchQueue(label: "com.morapay.securestore.queue", attributes: .concurrent)
    private let transactionLogKey = "com.morapay.encrypted_transaction_logs"
    private let accountStateKey = "com.morapay.account_freeze_state"
    
    private init() {}
    
    // MARK: - Secure Flag Persistence (Replaces UserDefaults for Booleans/States)
    public func setAccountFrozen(_ isFrozen: Bool) {
        let data = Data([isFrozen ? 1 : 0])
        _ = saveToKeychain(key: accountStateKey, data: data)
    }
    
    public func isAccountFrozen() -> Bool {
        guard let data = readFromKeychain(key: accountStateKey), let firstByte = data.first else {
            return false
        }
        return firstByte == 1
    }
    
    // MARK: - Encrypted Transaction Audit Log Persistence
    public func saveTransactionAuditLog(transactionId: String, amount: Double, riskScore: Double, isBlocked: Bool) {
        // Use async barrier to prevent writer/reader collision safely
        queue.async(flags: .barrier) {
            var existingLogs = self.fetchSynchronously()
            
            let logEntry: [String: Any] = [
                "id": transactionId,
                "amount": amount,
                "riskScore": riskScore,
                "isBlocked": isBlocked,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
            existingLogs.append(logEntry)
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: existingLogs, options: [])
                _ = self.saveToKeychain(key: self.transactionLogKey, data: jsonData)
            } catch {
                print("Failed to serialize audit logs: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchTransactionAuditLogs() -> [[String: Any]] {
        // Safe dispatch pattern: if we are already on our background queue,
        // fetch directly to avoid queue.sync deadlock; otherwise dispatch sync safely.
        if Thread.isMainThread {
            var logs: [[String: Any]] = []
            queue.sync {
                logs = self.fetchSynchronously()
            }
            return logs
        } else {
            return fetchSynchronously()
        }
    }
    
    private func fetchSynchronously() -> [[String: Any]] {
        guard let encryptedData = readFromKeychain(key: transactionLogKey) else { return [] }
        do {
            if let decodedArray = try JSONSerialization.jsonObject(with: encryptedData, options: []) as? [[String: Any]] {
                return decodedArray
            }
        } catch {
            print("Failed to decode audit logs: \(error.localizedDescription)")
        }
        return []
    }
    
    // MARK: - Low-Level iOS Keychain Encryption Helpers
    private func saveToKeychain(key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    private func readFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
}
