//
//  AccountManager.swift
//  SecurePay
//

import Foundation

public struct TransactionItem: Codable {
    public let title: String
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
        // Load saved balance or default to 14850.50 on first launch
        if UserDefaults.main.object(forKey: balanceKey) == nil {
            UserDefaults.main.set(14850.50, forKey: balanceKey)
        }

        // Load saved transactions or initialize with defaults on first launch
        if UserDefaults.main.data(forKey: transactionsKey) == nil {
            let defaultTransactions = [
                TransactionItem(title: "Apple Store", amount: "-$1,299.00", date: "Oct 21, 2026", iconName: "bag.fill", isCredit: false),
                TransactionItem(title: "Salary Deposit", amount: "+$4,500.00", date: "Oct 15, 2026", iconName: "arrow.down.circle.fill", isCredit: true),
                TransactionItem(title: "Starbucks Coffee", amount: "-$6.50", date: "Oct 14, 2026", iconName: "cup.and.saucer.fill", isCredit: false),
                TransactionItem(title: "Uber Ride", amount: "-$24.30", date: "Oct 12, 2026", iconName: "car.fill", isCredit: false)
            ]
            saveTransactions(defaultTransactions)
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

    public func processTransfer(to recipient: String, amount: Double) -> Bool {
        let current = currentBalance
        guard amount <= current else { return false }
        
        // Update balance (automatically triggers notification via setter)
        currentBalance = current - amount
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: Date())
        
        let newTransaction = TransactionItem(
            title: "Transfer to \(recipient)",
            amount: "-$\(String(format: "%.2f", amount))",
            date: dateString,
            iconName: "paperplane.fill",
            isCredit: false
        )
        
        var currentList = transactions
        currentList.insert(newTransaction, at: 0)
        
        // Update transactions (automatically triggers notification via setter)
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
