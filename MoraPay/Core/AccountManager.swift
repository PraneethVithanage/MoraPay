//
//  AccountManager.swift
//  SecurePay
//

import Foundation

public struct TransactionItem: Codable {
    public let bankName: String?
    public let accountName: String?
    public let accountNumber: String?
    public let amount: String
    public let date: String
    public let iconName: String
    public let isCredit: Bool
}

public class AccountManager {
    public static let shared = AccountManager()

    public static let balanceDidChangeNotification = Notification.Name("AccountBalanceDidChangeNotification")
    public static let transactionsDidChangeNotification = Notification.Name("AccountTransactionsDidChangeNotification")

    private let balanceKey = "saved_current_balance"
    private let transactionsKey = "saved_transactions_list"

    private init() {
        // Initialize balance to $100,000,000.00 on first launch
        if UserDefaults.main.object(forKey: balanceKey) == nil {
           // UserDefaults.main.set(100000000.00, forKey: balanceKey)
        }

    }

    public var currentBalance: Double {
        get {
            return UserDefaults.main.double(forKey: balanceKey)
        }
        set {
            UserDefaults.main.set(newValue, forKey: balanceKey)
            NotificationCenter.default.post(name: AccountManager.balanceDidChangeNotification, object: nil)
        }
    }

    public var transactions: [TransactionItem] {
        get {
            guard let data = UserDefaults.main.data(forKey: transactionsKey),
                  let decoded = try? JSONDecoder().decode([TransactionItem].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            saveTransactions(newValue)
            NotificationCenter.default.post(name: AccountManager.transactionsDidChangeNotification, object: nil)
        }
    }

    private func saveTransactions(_ items: [TransactionItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.main.set(encoded, forKey: transactionsKey)
        }
    }

    public func processTransfer(bankName: String, accountName: String, accountNumber: String, amount: Double) -> Bool {
        let current = currentBalance
        guard amount <= current else { return false }
         
        // Update balance
        currentBalance = current - amount

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy, hh:mm a"
        let dateString = dateFormatter.string(from: Date())

         
        let newTransaction = TransactionItem(
            bankName: bankName,
            accountName: accountName,
            accountNumber: accountNumber,
            amount: "-LKR \(String(format: "%.2f", amount))",
            date: dateString,
            iconName: "paperplane.fill",
            isCredit: false
        )
         
        var currentList = transactions
        currentList.insert(newTransaction, at: 0)
        transactions = currentList
         
        return true
    }
}

// Helper extension for concise syntax
extension UserDefaults {
    static var main: UserDefaults {
        return .standard
    }
}
