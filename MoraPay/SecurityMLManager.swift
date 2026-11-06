import Foundation
import LocalAuthentication
import Security

/// Represents incoming transaction telemetry parameters evaluated by Layer 1.
public struct TransactionTelemetry {
    let amount: Double
    let recipientAccountAgeDays: Int
    let transferVelocity1Min: Int
    let timeZScore: Double
    let isRootedOrJailbroken: Bool
}

/// Evaluation result containing the composite risk score, risk status, and human-readable factors.
public struct RiskEvaluationResult {
    let compositeScore: Double
    let isHighRisk: Bool
    let topRiskFactors: [String]
}

/// Production-ready 2-Layer Fraud Detection & JIT Intervention Engine for MoraPay.
public final class MoraPaySecurityEngine {
    
    public static let shared = MoraPaySecurityEngine()
    
    // Weights from thesis mathematical formulation: w1 + w2 + w3 = 1.0
    private let w1: Double = 0.35 // Deterministic rule penalty weight
    private let w2: Double = 0.45 // ML Ensemble probability weight
    private let w3: Double = 0.20 // Localized TreeSHAP attribution weight
    
    private let riskThreshold: Double = 0.75
    
    private init() {}
    
    // MARK: - Layer 1: Technical Fraud Detection Pipeline
    public func evaluateTransaction(_ telemetry: TransactionTelemetry) -> RiskEvaluationResult {
        // 1. Deterministic Rule Penalties (R_i)
        var rulePenalty: Double = 0.0
        var factors: [String] = []
        
        if telemetry.isRootedOrJailbroken {
            rulePenalty = 1.0
            factors.append("Device integrity compromise detected (Jailbroken/Rooted).")
        }
        if telemetry.transferVelocity1Min > 3 {
            rulePenalty = max(rulePenalty, 0.9)
            factors.append("High number of rapid transfer attempts.")
        }
        
        // 2. Simulated ML Ensemble Probability (P_ML)
        let mlProbability = calculateMLProbability(telemetry: telemetry)
        
        // 3. TreeSHAP Attribution Sum (Phi_k)
        let shapAttributionSum = computeSHAPAttributionSum(telemetry: telemetry)
        
        // Composite Anomaly Risk Score Formulation: S_total = w1*max(R_i) + w2*P_ML + w3*sum(Phi_k)
        let compositeScore = (w1 * rulePenalty) + (w2 * mlProbability) + (w3 * shapAttributionSum)
        let clampedScore = min(max(compositeScore, 0.0), 1.0)
        
        let isHighRisk = clampedScore > riskThreshold
        
        if isHighRisk && factors.isEmpty {
            factors.append(contentsOf: translateSHAPDrivers(telemetry: telemetry))
        }
        
        return RiskEvaluationResult(
            compositeScore: clampedScore,
            isHighRisk: isHighRisk,
            topRiskFactors: factors
        )
    }
    
    private func calculateMLProbability(telemetry: TransactionTelemetry) -> Double {
        let ageFactor = telemetry.recipientAccountAgeDays < 7 ? 0.85 : 0.05
        let velocityFactor = Double(telemetry.transferVelocity1Min) / 10.0
        let timeFactor = min(abs(telemetry.timeZScore) / 4.0, 1.0)
        
        return min((ageFactor * 0.5) + (velocityFactor * 0.3) + (timeFactor * 0.2), 1.0)
    }
    
    private func computeSHAPAttributionSum(telemetry: TransactionTelemetry) -> Double {
        var sum = 0.0
        if telemetry.recipientAccountAgeDays < 7 { sum += 0.4 }
        if abs(telemetry.timeZScore) > 2.5 { sum += 0.3 }
        if telemetry.transferVelocity1Min > 1 { sum += 0.3 }
        return min(sum, 1.0)
    }
    
    // MARK: - Layer 2: Explainable AI (TreeSHAP) Plain-Language Translation
    private func translateSHAPDrivers(telemetry: TransactionTelemetry) -> [String] {
        var translations: [String] = []
        if telemetry.recipientAccountAgeDays < 7 {
            translations.append("Recipient account was created very recently.")
        }
        if abs(telemetry.timeZScore) > 2.5 {
            translations.append("Unusual transfer time compared to your established patterns.")
        }
        if telemetry.transferVelocity1Min > 1 {
            translations.append("Multiple rapid transactions detected in a short window.")
        }
        if translations.isEmpty {
            translations.append("Unusual transaction profile detected requiring verification.")
        }
        return translations
    }
    
    // MARK: - Secure Storage & Keychain Services
    public func storeSecurePassphrase(_ key: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    // MARK: - Biometric Re-Authentication Handler (Face ID / Touch ID)
    public func requestBiometricReAuthentication(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(false)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: "Verify your identity to proceed with this high-risk transfer.") { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
