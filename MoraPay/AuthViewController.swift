//
//  AuthViewController.swift
//  MoraPay
//

import UIKit
import LocalAuthentication

public class AuthViewController: UIViewController {

    // University of Moratuwa Theme Colors
    private let moraGold = UIColor(red: 0.85, green: 0.60, blue: 0.15, alpha: 1.0)
    private let moraDarkBackground = UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0)
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let authenticateButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // REMOVED: viewDidAppear auto-trigger so Face ID won't popup automatically

    private func setupUI() {
        view.backgroundColor = moraDarkBackground

        // Moratuwa Logo Image
        logoImageView.image = UIImage(named: "mora_logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        // App Title
        titleLabel.text = "Welcome to MoraPay"
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Subtitle
        subtitleLabel.text = "University of Moratuwa Secure Banking Portal"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = moraGold
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Authenticate Button
        authenticateButton.setTitle("Unlock with Face ID", for: .normal)
        authenticateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        authenticateButton.backgroundColor = moraGold
        authenticateButton.setTitleColor(.black, for: .normal)
        authenticateButton.layer.cornerRadius = 16
        authenticateButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Face ID will ONLY trigger when user taps this button
        authenticateButton.addTarget(self, action: #selector(triggerBiometrics), for: .touchUpInside)

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(authenticateButton)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -110),
            logoImageView.widthAnchor.constraint(equalToConstant: 130),
            logoImageView.heightAnchor.constraint(equalToConstant: 130),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            authenticateButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            authenticateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            authenticateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            authenticateButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc private func triggerBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to unlock MoraPay."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
