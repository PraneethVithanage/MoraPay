//
//  TreeSHAPVisualizerViewController.swift
//  MoraPay
//
//  Created by C01LM101065 on 2026-11-06.
//

import UIKit

struct SHAPFeatureContribution {
    let featureName: String
    let shapValue: Double // Positive pushes towards fraud risk, negative pushes towards safe
}

class TreeSHAPVisualizerViewController: UIViewController {
    
    private var contributions: [SHAPFeatureContribution] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Real-Time TreeSHAP Explanation"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    init(contributions: [SHAPFeatureContribution]) {
        self.contributions = contributions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        populateChart()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func populateChart() {
        for item in contributions {
            let rowView = createFeatureRow(name: item.featureName, value: item.shapValue)
            stackView.addArrangedSubview(rowView)
        }
    }
    
    private func createFeatureRow(name: String, value: Double) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = name
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let barBackground = UIView()
        barBackground.backgroundColor = .systemGray5
        barBackground.layer.cornerRadius = 4
        barBackground.translatesAutoresizingMaskIntoConstraints = false
        
        let barFill = UIView()
        barFill.backgroundColor = value >= 0 ? .systemRed : .systemGreen // Red = Risk contributor, Green = Safe contributor
        barFill.layer.cornerRadius = 4
        barFill.translatesAutoresizingMaskIntoConstraints = false
        
        barBackground.addSubview(barFill)
        container.addSubview(label)
        container.addSubview(barBackground)
        
        // Calculate proportional width based on absolute SHAP magnitude (capped at 1.0)
        let maxAbs = max(contributions.map { abs($0.shapValue) }.max() ?? 1.0, 0.1)
        let ratio = CGFloat(abs(value) / maxAbs)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 36),
            
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 140),
            
            barBackground.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            barBackground.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            barBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            barBackground.heightAnchor.constraint(equalToConstant: 12),
            
            barFill.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
            barFill.centerYAnchor.constraint(equalTo: barBackground.centerYAnchor),
            barFill.heightAnchor.constraint(equalTo: barBackground.heightAnchor),
            barFill.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: max(min(ratio, 1.0), 0.05))
        ])
        
        return container
    }
}
