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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleTransactionsChange() {
        loadTransactions()
    }

    private func loadTransactions() {
        allTransactions = AccountManager.shared.transactions
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = filteredTransactions[indexPath.row]
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        cell.detailTextLabel?.text = item.date
        cell.detailTextLabel?.textColor = .gray

        let amountLabel = UILabel()
        amountLabel.text = item.amount
        amountLabel.textColor = item.isCredit ? primaryOrange : .lightGray
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        amountLabel.sizeToFit()
        cell.accessoryView = amountLabel

        cell.imageView?.image = UIImage(systemName: item.iconName)
        cell.imageView?.tintColor = primaryOrange

        return cell
    }
}
