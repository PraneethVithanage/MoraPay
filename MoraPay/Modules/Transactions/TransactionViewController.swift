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
        searchBar.placeholder = "Search transactions..."
        searchBar.barTintColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
        searchBar.searchTextField.textColor = .white
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        // Registering a custom or standard cell identifier properly for reuse optimization
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
        var items = AccountManager.shared.transactions
         
        let secureLogs = MoraPaySecureStore.shared.fetchTransactionAuditLogs()
        for log in secureLogs {
            let amountVal = log["amount"] as? Double ?? 0.0
            let isBlocked = log["isBlocked"] as? Bool ?? false
            let timestamp = log["timestamp"] as? String ?? ""
             
            let displayTitle = isBlocked ? "Blocked High-Risk Transfer" : "Secure Transfer"
            let amountString = String(format: "$%.2f", amountVal)
             
            let secureItem = TransactionItem(
                title: displayTitle,
                amount: amountString,
                date: timestamp,
                iconName: isBlocked ? "exclamationmark.shield.fill" : "arrow.up.right.circle.fill",
                isCredit: false
            )
            items.append(secureItem)
        }
         
        allTransactions = items
        filterContent(searchText: searchBar.text ?? "")
    }

    private func filterContent(searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredTransactions = allTransactions
        } else {
            filteredTransactions = allTransactions.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.amount.lowercased().contains(searchText.lowercased()) ||
                $0.date.lowercased().contains(searchText.lowercased())
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

// MARK: - Reusable Custom Cell for Performance and Layout Cleanliness
class TransactionCell: UITableViewCell {
    static let reuseIdentifier = "TransactionCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    func configure(with item: TransactionItem, primaryAccentColor: UIColor) {
        titleLabel.text = item.title
        dateLabel.text = item.date
        amountLabel.text = item.amount
        amountLabel.textColor = item.isCredit ? primaryAccentColor : .lightGray
        
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.tintColor = primaryAccentColor
    }
}
