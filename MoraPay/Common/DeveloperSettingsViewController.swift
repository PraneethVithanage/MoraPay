
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
        titleLabel.text = "Thesis Demo: Anomaly Time Mocking"
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

        // Preset Quick Action Buttons
        let btnAfternoon = createPresetButton(title: "Set Afternoon Anomaly (2:00 PM)", color: primaryOrange, action: #selector(setAfternoonTime))
        let btnNight = createPresetButton(title: "Set Late Night Window (11:00 PM)", color: .systemRed, action: #selector(setNightTime))
        let btnNormal = createPresetButton(title: "Set Normal Operating Hour (10:00 AM)", color: .systemGreen, action: #selector(setNormalTime))

        // Custom Time Picker
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        
        applyPickerButton.setTitle("Apply Selected Time", for: .normal)
        applyPickerButton.setTitleColor(.white, for: .normal)
        applyPickerButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        applyPickerButton.layer.cornerRadius = 12
        applyPickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        applyPickerButton.translatesAutoresizingMaskIntoConstraints = false
        applyPickerButton.addTarget(self, action: #selector(applyPickerTime), for: .touchUpInside)

        // Reset Button
        resetButton.setTitle("Reset to Real Device System Clock", for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetTime), for: .touchUpInside)

        // Stack View Container
        let stackView = UIStackView(arrangedSubviews: [
            btnAfternoon,
            btnNight,
            btnNormal
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(statusCardView)
        view.addSubview(stackView)
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

            stackView.topAnchor.constraint(equalTo: statusCardView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 150),

            timePicker.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.heightAnchor.constraint(equalToConstant: 120),

            applyPickerButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            applyPickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyPickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyPickerButton.heightAnchor.constraint(equalToConstant: 44),

            resetButton.topAnchor.constraint(equalTo: applyPickerButton.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func createPresetButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = color.withAlphaComponent(0.85)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    @objc private func setAfternoonTime() {
        DebugTimeManager.shared.simulatedHourOverride = 14 // 2:00 PM
        updateStatusDisplay()
    }

    @objc private func setNightTime() {
        DebugTimeManager.shared.simulatedHourOverride = 23 // 11:00 PM
        updateStatusDisplay()
    }

    @objc private func setNormalTime() {
        DebugTimeManager.shared.simulatedHourOverride = 10 // 10:00 AM
        updateStatusDisplay()
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
        let isNight = currentHour >= 22 && currentHour < 24
        let isAfternoon = currentHour >= 13 && currentHour < 17
        
        let zScore: Double
        if isNight {
            zScore = 2.5
        } else if isAfternoon {
            zScore = 3.5
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
