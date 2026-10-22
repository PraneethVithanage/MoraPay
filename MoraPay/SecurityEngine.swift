//
//  SecurityEngine.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class SecurityEngine: UIViewController {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Center"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        let shieldImageView = UIImageView(image: UIImage(systemName: "shield.checkered.shield.fill"))
        shieldImageView.tintColor = primaryOrange
        shieldImageView.contentMode = .scaleAspectFit
        shieldImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Orange Security Shield Active"
        label.textColor = primaryOrange
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(shieldImageView)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            shieldImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shieldImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            shieldImageView.widthAnchor.constraint(equalToConstant: 100),
            shieldImageView.heightAnchor.constraint(equalToConstant: 100),

            label.topAnchor.constraint(equalTo: shieldImageView.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    public func validateTransactionRisk(amount: Double) -> Bool {
        return amount < 10000.0
    }
}
