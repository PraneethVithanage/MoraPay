//
//  TransactionViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    private var allTransactions: [TransactionItem] = []
    private var filteredTransactions: [TransactionItem] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Transactions"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        searchBar.delegate = self
        searchBar.placeholder = "Search transactions, bank, or account..."
        searchBar.barTintColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
        searchBar.searchTextField.textColor = .white
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.rowHeight = 96 // Optimized height for 3 distinct text lines
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        loadTransactions()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTransactionsChange),
            name: AccountManager.transactionsDidChangeNotification,
            object: nil
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleTransactionsChange() {
        loadTransactions()
    }

    private func loadTransactions() {
            var items: [TransactionItem] = []
             
            // 1. Fetch encrypted secure audit logs and map to separated fields
            let secureLogs = MoraPaySecureStore.shared.fetchTransactionAuditLogs()
            for log in secureLogs {
                let bank = log["bankName"] as? String ?? "MoraPay Direct"
                let name = log["accountName"] as? String ?? "Transfer"
                let accountNo = log["accountNumber"] as? String ?? ""
                 
                // GUARD: Skip logs where the account number is empty or missing
                let trimmedAccount = accountNo.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedAccount.isEmpty || trimmedAccount == "N/A" {
                    continue
                }
                
                let amountVal = log["amount"] as? Double ?? 0.0
                let isBlocked = log["isBlocked"] as? Bool ?? false
                let timestamp = log["timestamp"] as? String ?? ""
                let amountString = String(format: "-LKR %.2f", amountVal)
                 
                let secureItem = TransactionItem(
                    bankName: bank,
                    accountName: name,
                    accountNumber: trimmedAccount,
                    amount: amountString,
                    date: timestamp,
                    iconName: isBlocked ? "exclamationmark.shield.fill" : "paperplane.fill",
                    isCredit: false
                )
                items.append(secureItem)
            }
             
            // 2. Append local persistent transactions from AccountManager (filtering out those with empty account numbers if needed)
            let localTransactions = AccountManager.shared.transactions.filter { item in
                guard let acc = item.accountNumber else { return false }
                return !acc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && acc != "N/A"
            }
            items.append(contentsOf: localTransactions)
             
            allTransactions = items
            filterContent(searchText: searchBar.text ?? "")
        }

    private func filterContent(searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredTransactions = allTransactions
        } else {
            filteredTransactions = allTransactions.filter { item in
                let bankMatch = item.bankName?.lowercased().contains(searchText.lowercased()) ?? false
                let nameMatch = item.accountName?.lowercased().contains(searchText.lowercased()) ?? false
                let accMatch = item.accountNumber?.lowercased().contains(searchText.lowercased()) ?? false
                //let titleMatch = item.title?.lowercased().contains(searchText.lowercased()) ?? false
                
                return bankMatch || nameMatch || accMatch  ||
                       item.amount.lowercased().contains(searchText.lowercased()) ||
                       item.date.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchText: searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseIdentifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
         
        let item = filteredTransactions[indexPath.row]
        cell.configure(with: item, primaryAccentColor: primaryOrange)
        return cell
    }
}

// MARK: - 3-Line Separate Custom Cell Layout
// MARK: - Custom Cell Layout with Bank, Name, Account Number, and Date
class TransactionCell: UITableViewCell {
    static let reuseIdentifier = "TransactionCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Line 1: Bank Name
    private let bankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Line 2: Recipient Account Name
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(white: 0.85, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Line 3: Account Number
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Line 4: Date Label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellDesign()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellDesign() {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(bankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(accountLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            // Left Action Icon
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Line 1: Bank Name
            bankLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            bankLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bankLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Line 2: Account Holder Name
            nameLabel.leadingAnchor.constraint(equalTo: bankLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: bankLabel.bottomAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Line 3: Account Number
            accountLabel.leadingAnchor.constraint(equalTo: bankLabel.leadingAnchor),
            accountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            accountLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Line 4: Date Label
            dateLabel.leadingAnchor.constraint(equalTo: bankLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 2),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Right Side: Amount Label
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
    }
    
    func configure(with item: TransactionItem, primaryAccentColor: UIColor) {
        if let bank = item.bankName, let name = item.accountName, let acc = item.accountNumber {
            // Structured transfer fields
            bankLabel.text = bank
            nameLabel.text = "Name: \(name)"
            accountLabel.text = "A/C: \(acc)"
        } else {
            // Fallback for default/legacy items
            bankLabel.text =  "Transaction"
            nameLabel.text = "Details: N/A"
            accountLabel.text = "A/C: N/A"
        }
        
        dateLabel.text = item.date
        amountLabel.text = item.amount
        amountLabel.textColor = item.isCredit ? primaryAccentColor : .lightGray
        
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.tintColor = primaryAccentColor
    }
}
