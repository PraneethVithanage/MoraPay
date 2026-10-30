//
//  AccountManager.swift
//  MoraPay
//
//  Created by C01LM101065 on 2026-10-30.
//

//
//  AccountManager.swift
//  SecurePay
//

import Foundation

public struct TransactionItem {
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

    private(set) public var currentBalance: Double = 14850.50
    private(set) public var transactions: [TransactionItem] = [
        TransactionItem(title: "Apple Store", amount: "-$1,299.00", date: "Oct 21, 2026", iconName: "bag.fill", isCredit: false),
        TransactionItem(title: "Salary Deposit", amount: "+$4,500.00", date: "Oct 15, 2026", iconName: "arrow.down.circle.fill", isCredit: true),
        TransactionItem(title: "Starbucks Coffee", amount: "-$6.50", date: "Oct 14, 2026", iconName: "cup.and.saucer.fill", isCredit: false),
        TransactionItem(title: "Uber Ride", amount: "-$24.30", date: "Oct 12, 2026", iconName: "car.fill", isCredit: false)
    ]

    private init() {}

    public func processTransfer(to recipient: String, amount: Double) -> Bool {
        guard amount <= currentBalance else { return false }
        
        currentBalance -= amount
        
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
        
        transactions.insert(newTransaction, at: 0)
        
        NotificationCenter.default.post(name: AccountManager.balanceDidChangeNotification, object: nil)
        NotificationCenter.default.post(name: AccountManager.transactionsDidChangeNotification, object: nil)
        
        return true
    }
}
