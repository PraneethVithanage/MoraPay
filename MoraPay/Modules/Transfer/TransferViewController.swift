//
//  TransferViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit
import LocalAuthentication

public class TransferViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)
    
    // Form fields
    private let bankTextField = UITextField()
    private let accountNameTextField = UITextField()
    private let accountNumberTextField = UITextField()
    private let amountTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // Bank Picker Data
    private let sriLankanBanks = [
        "Select Bank",
        "Bank of Ceylon (BOC)",
        "Sampath Bank PLC",
        "Commercial Bank of Ceylon",
        "Hatton National Bank (HNB)",
        "People's Bank",
        "DFCC Bank PLC",
        "National Development Bank (NDB)",
        "Seylan Bank PLC",
        "Nations Trust Bank (NTB)"
    ]
    private let bankPicker = UIPickerView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissal()
        setupPicker()
    }

    private func setupUI() {
        title = "Send Money"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        // 1. Bank Picker Text Field
        bankTextField.placeholder = "Select Recipient Bank"
        bankTextField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        bankTextField.textColor = .white
        bankTextField.layer.cornerRadius = 14
        bankTextField.delegate = self
        bankTextField.setLeftPaddingPoints(16)
        bankTextField.translatesAutoresizingMaskIntoConstraints = false

        // 2. Account Name Field
        accountNameTextField.placeholder = "Account Holder Name"
        accountNameTextField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        accountNameTextField.textColor = .white
        accountNameTextField.layer.cornerRadius = 14
        accountNameTextField.returnKeyType = .next
        accountNameTextField.delegate = self
        accountNameTextField.setLeftPaddingPoints(16)
        accountNameTextField.translatesAutoresizingMaskIntoConstraints = false

        // 3. Account Number Field
        accountNumberTextField.placeholder = "Account Number"
        accountNumberTextField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        accountNumberTextField.textColor = .white
        accountNumberTextField.layer.cornerRadius = 14
        accountNumberTextField.keyboardType = .numberPad
        accountNumberTextField.returnKeyType = .next
        accountNumberTextField.delegate = self
        accountNumberTextField.setLeftPaddingPoints(16)
        accountNumberTextField.translatesAutoresizingMaskIntoConstraints = false

        // 4. Amount Text Field Setup
        amountTextField.placeholder = "$0.00"
        amountTextField.font = UIFont.systemFont(ofSize: 38, weight: .bold)
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

        view.addSubview(bankTextField)
        view.addSubview(accountNameTextField)
        view.addSubview(accountNumberTextField)
        view.addSubview(amountTextField)
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            bankTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bankTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bankTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bankTextField.heightAnchor.constraint(equalToConstant: 50),

            accountNameTextField.topAnchor.constraint(equalTo: bankTextField.bottomAnchor, constant: 16),
            accountNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accountNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            accountNameTextField.heightAnchor.constraint(equalToConstant: 50),

            accountNumberTextField.topAnchor.constraint(equalTo: accountNameTextField.bottomAnchor, constant: 16),
            accountNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            accountNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            accountNumberTextField.heightAnchor.constraint(equalToConstant: 50),

            amountTextField.topAnchor.constraint(equalTo: accountNumberTextField.bottomAnchor, constant: 30),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupPicker() {
        bankPicker.delegate = self
        bankPicker.dataSource = self
        bankTextField.inputView = bankPicker
         
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([UIBarButtonItem(systemItem: .flexibleSpace), doneButton], animated: false)
        bankTextField.inputAccessoryView = toolbar
    }

    @objc private func dismissPicker() {
        bankTextField.resignFirstResponder()
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UIPickerView DataSource & Delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sriLankanBanks.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sriLankanBanks[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            bankTextField.text = ""
        } else {
            bankTextField.text = sriLankanBanks[row]
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == bankTextField {
            accountNameTextField.becomeFirstResponder()
        } else if textField == accountNameTextField {
            accountNumberTextField.becomeFirstResponder()
        } else if textField == accountNumberTextField {
            amountTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func handleSend() {
        dismissKeyboard()
         
        guard let bank = bankTextField.text, !bank.isEmpty else {
            showAlert(title: "Missing Bank", message: "Please select a recipient bank.")
            return
        }

        guard let accountName = accountNameTextField.text, !accountName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter the account holder's name.")
            return
        }

        guard let accountNumber = accountNumberTextField.text, !accountNumber.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing Account Number", message: "Please enter a valid account number.")
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
     
        // --- ML FRAUD RISK ANALYSIS ---
        let alert = UIAlertController(title: "Analyzing Transaction...", message: "Running on-device ML security model...", preferredStyle: .alert)
        present(alert, animated: true)
         
        let telemetry = TransactionTelemetry(
            amount: amount,
            recipientAccountAgeDays: 2,
            transferVelocity1Min: 1,
            timeZScore: 0.8,
            isRootedOrJailbroken: false
        )
         
        let analysisResult = MoraPaySecurityEngine.shared.evaluateTransaction(telemetry)
         
        // Securely record audit log via encrypted store
        MoraPaySecureStore.shared.saveDetailedTransactionAuditLog(
            transactionId: UUID().uuidString,
            amount: amount,
            bankName: bank,
            accountName: accountName,
            accountNumber: accountNumber,
            riskScore: analysisResult.compositeScore,
            isBlocked: analysisResult.isHighRisk
        )
         
        alert.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
             
            let percentage = Int(analysisResult.compositeScore * 100)
             
            if analysisResult.isHighRisk {
                let factorsText = analysisResult.topRiskFactors.joined(separator: "\n• ")
                self.showAlert(
                    title: "⚠️ High Fraud Risk Detected (\(percentage)%)",
                    message: "Our ML security model flagged this transfer due to the following indicators:\n• \(factorsText)"
                )
            } else {
                // Low Risk -> Proceed to Biometric Auth & Transfer
                self.promptBiometricsAndExecute(
                    bank: bank,
                    accountName: accountName,
                    accountNumber: accountNumber,
                    amount: amount
                )
            }
        }
    }

    private func promptBiometricsAndExecute(bank: String, accountName: String, accountNumber: String, amount: Double) {
        let context = LAContext()
        var error: NSError?

        let executePayment = { [weak self] in
            guard let self = self else { return }
            let success = AccountManager.shared.processTransfer(
                bankName: bank,
                accountName: accountName,
                accountNumber: accountNumber,
                amount: amount
            )
            if success {
                let alert = UIAlertController(title: "Transfer Complete", message: "Successfully sent $\(String(format: "%.2f", amount)) to \(accountName).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            } else {
                self.showAlert(title: "Error", message: "Unable to process transfer. Please try again.")
            }
        }

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Confirm payment of $\(amount) to \(accountName)") { success, _ in
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
