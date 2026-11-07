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
        titleLabel.text = "Anomaly Time Mocking"
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
        view.addSubview(resetButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            statusCardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            statusCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: statusCardView.topAnchor, constant: 14),
            statusLabel.bottomAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: -14),
            statusLabel.leadingAnchor.constraint(equalTo: statusCardView.leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(equalTo: statusCardView.trailingAnchor, constant: -14),

            timePicker.topAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: 30),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.heightAnchor.constraint(equalToConstant: 180),

            applyPickerButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20),
            applyPickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyPickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyPickerButton.heightAnchor.constraint(equalToConstant: 50),

            resetButton.topAnchor.constraint(equalTo: applyPickerButton.bottomAnchor, constant: 16),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func applyPickerTime() {
        let hour = Calendar.current.component(.hour, from: timePicker.date)
        DebugTimeManager.shared.simulatedHourOverride = hour
        updateStatusDisplay()
    }

    @objc private func resetTime() {
        DebugTimeManager.shared.simulatedHourOverride = nil
        updateStatusDisplay()
    }

    private func updateStatusDisplay() {
            let currentHour = DebugTimeManager.shared.getCurrentHour()
            
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
            • Simulated App Hour: \(currentHour):00
            • Evaluated timeZScore: \(zScore)
            """
        }
}
