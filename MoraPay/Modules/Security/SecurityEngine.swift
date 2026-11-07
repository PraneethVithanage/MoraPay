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
    private let auditLogTextView = UITextView()
    private let inspectShapButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Security Center"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        // Add Trash button to clear logs during demo
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(confirmClearLogs)
        )

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

        statusDetailsLabel.text = "• Biometric Authentication: Active\n• Fraud Rule Engine: Active\n• JIT TreeSHAP Explainer: Enabled"
        statusDetailsLabel.textColor = .lightGray
        statusDetailsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statusDetailsLabel.numberOfLines = 0
        statusDetailsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Audit Log Text View for Flagged Alerts
        auditLogTextView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        auditLogTextView.textColor = .white
        auditLogTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        auditLogTextView.layer.cornerRadius = 12
        auditLogTextView.isEditable = false
        auditLogTextView.translatesAutoresizingMaskIntoConstraints = false

        // Inspect SHAP Visualizer Button
        inspectShapButton.setTitle("Inspect Last AI Feature Attributions (SHAP)", for: .normal)
        inspectShapButton.setTitleColor(.white, for: .normal)
        inspectShapButton.backgroundColor = UIColor(red: 0.20, green: 0.50, blue: 0.80, alpha: 1.0)
        inspectShapButton.layer.cornerRadius = 12
        inspectShapButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        inspectShapButton.translatesAutoresizingMaskIntoConstraints = false
        inspectShapButton.addTarget(self, action: #selector(openShapVisualizer), for: .touchUpInside)

        statusCardView.addSubview(statusDetailsLabel)
        statusCardView.addSubview(auditLogTextView)
        statusCardView.addSubview(inspectShapButton)
        
        view.addSubview(shieldImageView)
        view.addSubview(headerLabel)
        view.addSubview(statusCardView)

        NSLayoutConstraint.activate([
            shieldImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shieldImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            shieldImageView.widthAnchor.constraint(equalToConstant: 70),
            shieldImageView.heightAnchor.constraint(equalToConstant: 70),

            headerLabel.topAnchor.constraint(equalTo: shieldImageView.bottomAnchor, constant: 10),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusCardView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 15),
            statusCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusCardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            statusDetailsLabel.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 16),
            statusDetailsLabel.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 16),
            statusDetailsLabel.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -16),

            auditLogTextView.topAnchor.constraint(equalTo: statusDetailsLabel.bottomAnchor, constant: 12),
            auditLogTextView.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 16),
            auditLogTextView.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -16),
            auditLogTextView.bottomAnchor.constraint(equalTo: inspectShapButton.topAnchor, constant: -12),

            inspectShapButton.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 16),
            inspectShapButton.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -16),
            inspectShapButton.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -16),
            inspectShapButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAuditLogsIntoView()
    }
    
    private func loadAuditLogsIntoView() {
        let records = FraudAuditManager.shared.records
        if records.isEmpty {
            auditLogTextView.text = "📋 Flagged Fraud Audit Log:\n\nNo high-risk transactions recorded yet. Test rapid transfers or late-night times to generate logs."
        } else {
            var logText = "📋 Flagged Fraud Audit Log (\(records.count)):\n\n"
            for (index, rec) in records.enumerated() {
                logText += "[\(index + 1)] Time: \(rec.timestamp)\n"
                logText += "• Amount: LKR \(String(format: "%.2f", rec.amount))\n"
                logText += "• Risk Score: \(rec.riskScore)%\n"
                logText += "• Factors: \(rec.factors)\n"
                logText += "-----------------------------------\n"
            }
            auditLogTextView.text = logText
        }
    }

    @objc private func openShapVisualizer() {
        let sampleContributions = [
            SHAPFeatureContribution(featureName: "Time Z-Score", shapValue: 0.42),
            SHAPFeatureContribution(featureName: "Transaction Amount", shapValue: 0.35),
            SHAPFeatureContribution(featureName: "Transfer Velocity", shapValue: 0.15),
            SHAPFeatureContribution(featureName: "Account Age", shapValue: -0.10)
        ]
        
        let visualizerVC = TreeSHAPVisualizerViewController(contributions: sampleContributions)
        navigationController?.pushViewController(visualizerVC, animated: true)
    }

    @objc private func confirmClearLogs() {
        let alert = UIAlertController(title: "Clear Audit Logs", message: "Are you sure you want to clear all recorded high-risk security audit entries?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            FraudAuditManager.shared.clearLogs()
            self?.loadAuditLogsIntoView()
        })
        present(alert, animated: true)
    }

    public func validateTransactionRisk(amount: Double) -> Bool {
        return amount <= 10000.0
    }
}
