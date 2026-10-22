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

    private let transactions = [
        ("Apple Store", "-$1,299.00", "Oct 21, 2026", "bag.fill"),
        ("Salary Deposit", "+$4,500.00", "Oct 15, 2026", "arrow.down.circle.fill"),
        ("Starbucks Coffee", "-$6.50", "Oct 14, 2026", "cup.and.saucer.fill"),
        ("Uber Ride", "-$24.30", "Oct 12, 2026", "car.fill")
    ]

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
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = transactions[indexPath.row]
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        cell.textLabel?.text = item.0
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        cell.detailTextLabel?.text = item.2
        cell.detailTextLabel?.textColor = .gray

        let amountLabel = UILabel()
        amountLabel.text = item.1
        amountLabel.textColor = item.1.contains("+") ? primaryOrange : .lightGray
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        amountLabel.sizeToFit()
        cell.accessoryView = amountLabel

        cell.imageView?.image = UIImage(systemName: item.3)
        cell.imageView?.tintColor = primaryOrange

        return cell
    }
}
