//
//  CardsViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class CardsViewController: UIViewController {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let cardGradientStart = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let cardGradientEnd = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)

    private let cardContainerView = UIView()
    private let cardNumberLabel = UILabel()
    private let cardHolderLabel = UILabel()
    private let cardExpiryLabel = UILabel()
    private let freezeButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient layer automatically adapts to card container bounds on layout changes
        if let gradientLayer = cardContainerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = cardContainerView.bounds
        }
    }

    private func setupUI() {
        title = "Virtual Cards"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        // Navigation Bar Appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = navAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance

        // Card Container View
        cardContainerView.layer.cornerRadius = 24
        cardContainerView.clipsToBounds = true
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainerView)

        // Orange Gradient Layer with correct bounds
        let gradient = CAGradientLayer()
        gradient.colors = [cardGradientStart.cgColor, cardGradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 200)
        cardContainerView.layer.insertSublayer(gradient, at: 0)

        // Card Details Labels
        cardNumberLabel.text = "4532 •••• •••• 8842"
        cardNumberLabel.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .bold)
        cardNumberLabel.textColor = .white
        cardNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        cardHolderLabel.text = "ALEX MORGAN"
        cardHolderLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cardHolderLabel.textColor = .white
        cardHolderLabel.translatesAutoresizingMaskIntoConstraints = false

        cardExpiryLabel.text = "09/29"
        cardExpiryLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        cardExpiryLabel.textColor = .white
        cardExpiryLabel.translatesAutoresizingMaskIntoConstraints = false

        cardContainerView.addSubview(cardNumberLabel)
        cardContainerView.addSubview(cardHolderLabel)
        cardContainerView.addSubview(cardExpiryLabel)

        // Freeze Card Button
        freezeButton.setTitle("Freeze Card", for: .normal)
        freezeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        freezeButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        freezeButton.setTitleColor(primaryOrange, for: .normal)
        freezeButton.layer.cornerRadius = 16
        freezeButton.layer.borderWidth = 1
        freezeButton.layer.borderColor = primaryOrange.withAlphaComponent(0.4).cgColor
        freezeButton.translatesAutoresizingMaskIntoConstraints = false
        freezeButton.addTarget(self, action: #selector(toggleFreeze), for: .touchUpInside)

        view.addSubview(freezeButton)

        // AutoLayout Constraints
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.heightAnchor.constraint(equalToConstant: 200),

            cardNumberLabel.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            cardNumberLabel.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor, constant: -10),

            cardHolderLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 20),
            cardHolderLabel.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -20),

            cardExpiryLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -20),
            cardExpiryLabel.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -20),

            freezeButton.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: 24),
            freezeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            freezeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            freezeButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func toggleFreeze() {
        let isFrozen = freezeButton.title(for: .normal) == "Freeze Card"
        freezeButton.setTitle(isFrozen ? "Unfreeze Card" : "Freeze Card", for: .normal)
        freezeButton.backgroundColor = isFrozen ? primaryOrange.withAlphaComponent(0.2) : UIColor.white.withAlphaComponent(0.08)
    }
}
