//
//  DebugTimeManager.swift.swift
//  MoraPay
//
//  Created by C01LM101065 on 2026-11-07.
//

import Foundation

public class DebugTimeManager {
    public static let shared = DebugTimeManager()
    
    /// Holds the manual hour override (0...23). If nil, the app uses live device time.
    public var simulatedHourOverride: Int? = nil
    
    private init() {}
    
    /// Helper method evaluated by MoraPaySecurityEngine/TransferViewController
    public func getCurrentHour() -> Int {
        if let override = simulatedHourOverride {
            return override
        }
        return Calendar.current.component(.hour, from: Date())
    }
}
