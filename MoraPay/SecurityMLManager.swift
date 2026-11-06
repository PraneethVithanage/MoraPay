//
//  SecurityMLManager.swift
//  SecurePay
//

import Foundation

public struct FraudAnalysisResult {
    public let riskScore: Float
    public let isFlagged: Bool
    public let riskFactors: [String]
}

public class SecurityMLManager {

    public static let shared = SecurityMLManager()

    private init() {}

    /// Simulates a multi-feature on-device ML anomaly detection model (e.g., Logistic Regression / Random Forest inference)
    public func analyzeFraudRisk(accountID: String, amount: Double, completion: @escaping (FraudAnalysisResult) -> Void) {
        // Simulate CoreML inference latency (e.g., processing tensor inputs)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45) {
            var riskScore: Float = 0.05 // Base background risk
            var factors: [String] = []

            // 1. Amount Anomaly Feature (Z-Score simulation)
            if amount > 8000.0 {
                riskScore += 0.55
                factors.append("Extreme amount deviation from user baseline")
            } else if amount > 3000.0 {
                riskScore += 0.30
                factors.append("Moderate high-value transaction anomaly")
            }

            // 2. Recipient / Behavioral Trust Feature
            let highRiskKeywords = ["suspicious", "unknown", "hack", "test", "anonymous", "scam"]
            if highRiskKeywords.contains(where: { accountID.lowercased().contains($0) }) {
                riskScore += 0.60
                factors.append("Recipient entity flagged in global threat intelligence database")
            }

            // 3. Temporal / Time-of-Day Anomaly Feature (Simulating unusual late-night activity)
            let currentHour = Calendar.current.component(.hour, from: Date())
            if currentHour >= 1 && currentHour <= 4 {
                riskScore += 0.20
                factors.append("Anomalous activity timestamp (Late-night transaction window)")
            }

            // Cap final risk score between 0.0 and 1.0
            let finalScore = min(max(riskScore, 0.0), 1.0)
            let isFlagged = finalScore > 0.50

            let result = FraudAnalysisResult(
                riskScore: finalScore,
                isFlagged: isFlagged,
                riskFactors: factors.isEmpty ? ["Standard behavioral pattern verified"] : factors
            )

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
