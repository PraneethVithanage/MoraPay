

import UIKit

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

    /// Tap anywhere outside text fields to dismiss keyboard
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == recipientTextField {
            amountTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func handleSend() {
        dismissKeyboard() // Dismiss keyboard before presenting modal action
        
        let alert = UIAlertController(
            title: "Biometric Authentication",
            message: "Authenticate with Face ID / Touch ID to confirm orange transfer.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Authenticate", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
