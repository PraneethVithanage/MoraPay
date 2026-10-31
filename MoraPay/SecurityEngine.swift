//
//  SecurityEngine.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class SecurityEngine: UIViewController {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let statusCardView = UIView()
    private let statusDetailsLabel = UILabel()

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Center"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        let shieldImageView = UIImageView(image: UIImage(systemName: "shield.checkered.shield.fill"))
        shieldImageView.tintColor = primaryOrange
        shieldImageView.contentMode = .scaleAspectFit
        shieldImageView.translatesAutoresizingMaskIntoConstraints = false

        let headerLabel = UILabel()
        headerLabel.text = "Orange Security Shield Active"
        headerLabel.textColor = primaryOrange
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        statusCardView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        statusCardView.layer.cornerRadius = 16
        statusCardView.layer.borderWidth = 1
        statusCardView.layer.borderColor = primaryOrange.withAlphaComponent(0.3).cgColor
        statusCardView.translatesAutoresizingMaskIntoConstraints = false

        statusDetailsLabel.text = "• Biometric Authentication: Active\n• Single Transfer Limit: $10,000.00\n• Fraud Rule Engine: Active"
        statusDetailsLabel.textColor = .lightGray
        statusDetailsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusDetailsLabel.numberOfLines = 0
        statusDetailsLabel.translatesAutoresizingMaskIntoConstraints = false

        statusCardView.addSubview(statusDetailsLabel)
        view.addSubview(shieldImageView)
        view.addSubview(headerLabel)
        view.addSubview(statusCardView)

        NSLayoutConstraint.activate([
            shieldImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shieldImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            shieldImageView.widthAnchor.constraint(equalToConstant: 90),
            shieldImageView.heightAnchor.constraint(equalToConstant: 90),

            headerLabel.topAnchor.constraint(equalTo: shieldImageView.bottomAnchor, constant: 20),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusCardView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 30),
            statusCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusDetailsLabel.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 16),
            statusDetailsLabel.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -16),
            statusDetailsLabel.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 16),
            statusDetailsLabel.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -16)
        ])
    }

    public func validateTransactionRisk(amount: Double) -> Bool {
        return amount <= 10000.0
    }
}
