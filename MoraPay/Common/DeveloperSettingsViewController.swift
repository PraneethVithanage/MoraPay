//
//  DeveloperSettingsViewController.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import UIKit

public class DeveloperSettingsViewController: UIViewController {

    private let titleLabel = UILabel()
    private let statusCardView = UIView()
    private let statusLabel = UILabel()
    private let timePicker = UIDatePicker()
    private let applyPickerButton = UIButton(type: .system)
    private let otaSyncButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    
    private let primaryOrange = UIColor(red: 0.96, green: 0.65, blue: 0.13, alpha: 1.0)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatusDisplay()
    }

    private func setupUI() {
        title = "Developer & Test Settings"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)

        // Header Title
        titleLabel.text = "Anomaly Time & OTA Model Mocking"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Active Status Card View
        statusCardView.layer.cornerRadius = 14
        statusCardView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        statusCardView.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusCardView.addSubview(statusLabel)

        // Custom Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        
        applyPickerButton.setTitle("Apply Selected Time", for: .normal)
        applyPickerButton.setTitleColor(.white, for: .normal)
        applyPickerButton.backgroundColor = primaryOrange
        applyPickerButton.layer.cornerRadius = 12
        applyPickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        applyPickerButton.translatesAutoresizingMaskIntoConstraints = false
        applyPickerButton.addTarget(self, action: #selector(applyPickerTime), for: .touchUpInside)

        // OTA Sync Button
        otaSyncButton.setTitle("Check & Sync OTA Model Weights", for: .normal)
        otaSyncButton.setTitleColor(.white, for: .normal)
        otaSyncButton.backgroundColor = UIColor(red: 0.20, green: 0.50, blue: 0.80, alpha: 1.0)
        otaSyncButton.layer.cornerRadius = 12
        otaSyncButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        otaSyncButton.translatesAutoresizingMaskIntoConstraints = false
        otaSyncButton.addTarget(self, action: #selector(triggerOTACheck), for: .touchUpInside)

        // Reset Button
        resetButton.setTitle("Reset to Real Device System Clock", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetTime), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(statusCardView)
        view.addSubview(timePicker)
        view.addSubview(applyPickerButton)
        view.addSubview(otaSyncButton)
        view.addSubview(resetButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            statusCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            statusCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -12),
            statusLabel.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -14),

            timePicker.topAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: 15),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.heightAnchor.constraint(equalToConstant: 140),

            applyPickerButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 12),
            applyPickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyPickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyPickerButton.heightAnchor.constraint(equalToConstant: 46),

            otaSyncButton.topAnchor.constraint(equalTo: applyPickerButton.bottomAnchor, constant: 12),
            otaSyncButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            otaSyncButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            otaSyncButton.heightAnchor.constraint(equalToConstant: 46),

            resetButton.topAnchor.constraint(equalTo: otaSyncButton.bottomAnchor, constant: 12),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func applyPickerTime() {
        let hour = Calendar.current.component(.hour, from: timePicker.date)
        DebugTimeManager.shared.simulatedHourOverride = hour
        updateStatusDisplay()
    }

    @objc private func triggerOTACheck() {
        let currentVersion = UserDefaults.standard.string(forKey: "MoraPay_ActiveModelVersion") ?? "v1.0.0"
        
        let alert = UIAlertController(title: "OTA Model Sync", message: "Connecting to MoraPay secure servers...", preferredStyle: .alert)
        present(alert, animated: true)
        
        ModelOTASyncManager.shared.checkForUpdates(currentVersion: currentVersion) { success, newVersion in
            DispatchQueue.main.async {
                alert.dismiss(animated: true) {
                    let resultAlert: UIAlertController
                    if success, let version = newVersion {
                        resultAlert = UIAlertController(title: "Update Successful 🎉", message: "Downloaded and installed new ML model weights (Version: \(version)).", preferredStyle: .alert)
                    } else {
                        resultAlert = UIAlertController(title: "Up to Date", message: "Active model version (\(currentVersion)) is already up to date.", preferredStyle: .alert)
                    }
                    resultAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(resultAlert, animated: true)
                }
            }
        }
    }

    @objc private func resetTime() {
        DebugTimeManager.shared.simulatedHourOverride = nil
        updateStatusDisplay()
    }

    private func updateStatusDisplay() {
        let currentHour = DebugTimeManager.shared.getCurrentHour()
        let activeModelVersion = UserDefaults.standard.string(forKey: "MoraPay_ActiveModelVersion") ?? "v1.0.0"
        
        let isNormalWindow = currentHour >= 5 && currentHour < 22
        let isLateNightWindow = currentHour >= 22 && currentHour < 24
        let isDeepNightWindow = currentHour >= 0 && currentHour < 5
        
        let zScore: Double
        if isDeepNightWindow {
            zScore = 3.5
        } else if isLateNightWindow {
            zScore = 2.0
        } else {
            zScore = 0.8
        }

        let modeText = DebugTimeManager.shared.simulatedHourOverride != nil ? "MANUAL MOCK ACTIVE" : "REAL DEVICE CLOCK"
        statusLabel.text = """
        • Mode: \(modeText)
        • Active Model Version: \(activeModelVersion)
        • Simulated App Hour: \(currentHour):00
        • Evaluated timeZScore: \(zScore)
        """
    }
}
