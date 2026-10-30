//
//  BankHomeViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class BankHomeViewController: UIViewController {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let darkBackground = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
    private let cardGradientStart = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let cardGradientEnd = UIColor(red: 0.85, green: 0.25, blue: 0.0, alpha: 1.0)

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let balanceCardView = UIView()
    private let balanceLabel = UILabel()
    private let quickActionsStack = UIStackView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
        updateBalanceDisplay()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBalanceChange),
            name: AccountManager.balanceDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleBalanceChange() {
        updateBalanceDisplay()
    }

    private func updateBalanceDisplay() {
        let current = AccountManager.shared.currentBalance
        balanceLabel.text = String(format: "$%.2f", current)
    }

    private func setupUI() {
        view.backgroundColor = darkBackground
        title = "SecurePay"

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = darkBackground
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = navAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance

        // 1. Scrollable Container View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 2. Orange Gradient Balance Card
        balanceCardView.layer.cornerRadius = 24
        balanceCardView.clipsToBounds = true
        balanceCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(balanceCardView)

        let gradient = CAGradientLayer()
        gradient.colors = [cardGradientStart.cgColor, cardGradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 180)
        balanceCardView.layer.insertSublayer(gradient, at: 0)

        balanceLabel.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.addSubview(balanceLabel)

        // 3. Quick Action Buttons
        let sendBtn = createActionButton(title: "Send", iconName: "paperplane.fill") { [weak self] in
            let transferVC = TransferViewController()
            self?.navigationController?.pushViewController(transferVC, animated: true)
        }

        let historyBtn = createActionButton(title: "Activity", iconName: "clock.arrow.circlepath") { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }

        let securityBtn = createActionButton(title: "Security", iconName: "shield.checkmark.fill") { [weak self] in
            self?.tabBarController?.selectedIndex = 4
        }

        quickActionsStack.axis = .horizontal
        quickActionsStack.distribution = .fillEqually
        quickActionsStack.spacing = 16
        quickActionsStack.translatesAutoresizingMaskIntoConstraints = false
        quickActionsStack.addArrangedSubview(sendBtn)
        quickActionsStack.addArrangedSubview(historyBtn)
        quickActionsStack.addArrangedSubview(securityBtn)
        contentView.addSubview(quickActionsStack)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            balanceCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            balanceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            balanceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            balanceCardView.heightAnchor.constraint(equalToConstant: 180),

            balanceLabel.centerXAnchor.constraint(equalTo: balanceCardView.centerXAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: balanceCardView.centerYAnchor),

            quickActionsStack.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: 24),
            quickActionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickActionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickActionsStack.heightAnchor.constraint(equalToConstant: 70),
            quickActionsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func createActionButton(title: String, iconName: String, action: @escaping () -> Void) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = primaryOrange.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 16
        btn.layer.borderColor = primaryOrange.cgColor
        btn.layer.borderWidth = 1

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: iconName)
        config.imagePlacement = .top
        config.imagePadding = 6
        config.baseForegroundColor = primaryOrange
        btn.configuration = config

        btn.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
        return btn
    }
}
