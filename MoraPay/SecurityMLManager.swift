//
//  SecurityMLManager.swift
//  SecurePay
//
//  Created by Praneeth Vithanage on 2026-10-14.
//

import Foundation

public class SecurityMLManager {

    public static let shared = SecurityMLManager()

    private init() {}

    public func analyzeFraudRisk(accountID: String, amount: Double = 0.0, completion: @escaping (Float) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let riskScore: Float = 0.02
            DispatchQueue.main.async {
                completion(riskScore)
            }
        }
    }
}
