//
//  TransferViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit
import LocalAuthentication

public class TransferViewController: UIViewController, UITextFieldDelegate {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    private let recipientTextField = UITextField()
    private let amountTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        title = "Send Money"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        // Recipient Text Field Setup
        recipientTextField.placeholder = "Recipient Username or Email"
        recipientTextField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        recipientTextField.textColor = .white
        recipientTextField.layer.cornerRadius = 14
        recipientTextField.returnKeyType = .next
        recipientTextField.delegate = self
        recipientTextField.setLeftPaddingPoints(16)
        recipientTextField.translatesAutoresizingMaskIntoConstraints = false

        // Amount Text Field Setup
        amountTextField.placeholder = "$0.00"
        amountTextField.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        amountTextField.textColor = primaryOrange
        amountTextField.textAlignment = .center
        amountTextField.keyboardType = .decimalPad
        amountTextField.returnKeyType = .done
        amountTextField.delegate = self
        amountTextField.translatesAutoresizingMaskIntoConstraints = false

        // Confirm Button Setup
        sendButton.setTitle("Confirm & Pay", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        sendButton.backgroundColor = primaryOrange
        sendButton.layer.cornerRadius = 16
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)

        view.addSubview(recipientTextField)
        view.addSubview(amountTextField)
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            recipientTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            recipientTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recipientTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recipientTextField.heightAnchor.constraint(equalToConstant: 52),

            amountTextField.topAnchor.constraint(equalTo: recipientTextField.bottomAnchor, constant: 40),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == recipientTextField {
            amountTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func handleSend() {
        dismissKeyboard()
        
        guard let recipient = recipientTextField.text, !recipient.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a recipient username or email.")
            return
        }

        let rawAmount = (amountTextField.text ?? "").replacingOccurrences(of: "$", with: "")
        guard let amount = Double(rawAmount), amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid transfer amount greater than zero.")
            return
        }

        let securityEngine = SecurityEngine()
        if !securityEngine.validateTransactionRisk(amount: amount) {
            showAlert(title: "Transfer Limit Exceeded", message: "Single transfers over $10,000.00 require branch verification.")
            return
        }

        if amount > AccountManager.shared.currentBalance {
            showAlert(title: "Insufficient Balance", message: "You do not have enough funds to complete this transaction.")
            return
        }

        promptBiometricsAndExecute(recipient: recipient, amount: amount)
    }

    private func promptBiometricsAndExecute(recipient: String, amount: Double) {
        let context = LAContext()
        var error: NSError?

        let executePayment = { [weak self] in
            guard let self = self else { return }
            let success = AccountManager.shared.processTransfer(to: recipient, amount: amount)
            if success {
                let alert = UIAlertController(title: "Transfer Complete", message: "Successfully sent $\(String(format: "%.2f", amount)) to \(recipient).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            } else {
                self.showAlert(title: "Error", message: "Unable to process transfer. Please try again.")
            }
        }

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Confirm payment of $\(amount) to \(recipient)") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        executePayment()
                    } else {
                        self.showAlert(title: "Authentication Failed", message: "Biometric authentication failed. Transfer was not completed.")
                    }
                }
            }
        } else {
            executePayment()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextField Extension for Inner Padding
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
