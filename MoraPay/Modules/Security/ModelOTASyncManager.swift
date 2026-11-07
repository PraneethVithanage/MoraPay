//
//  ModelOTASyncManager.swift
//  MoraPay
//
//  Created by C01LM101065 on 2026-11-06.
//

import Foundation
import Security

class ModelOTASyncManager {
    static let shared = ModelOTASyncManager()
    
    private let modelEndpoint = URL(string: "https://api.morapay.lk/v1/ml/weights/latest")!
    private let localModelFileName = "MoraPayFraudDetectionModel.mlmodelc"
    
    private init() {}
    
    /// Checks for model updates over-the-air (OTA) and downloads if a newer version exists.
    func checkForUpdates(currentVersion: String, completion: @escaping (Bool, String?) -> Void) {
        var request = URLRequest(url: modelEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["current_version": currentVersion]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let updateAvailable = json["update_available"] as? Bool,
                   updateAvailable,
                   let downloadURLStr = json["download_url"] as? String,
                   let downloadURL = URL(string: downloadURLStr),
                   let newVersion = json["version"] as? String {
                    
                    self.downloadAndInstallWeights(from: downloadURL, version: newVersion) { success in
                        completion(success, newVersion)
                    }
                } else {
                    completion(false, nil)
                }
            } catch {
                completion(false, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func downloadAndInstallWeights(from url: URL, version: String, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                completion(false)
                return
            }
            
            do {
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(self.localModelFileName)
                
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                try fileManager.moveItem(at: tempURL, to: destinationURL)
                
                // Save synced version state
                UserDefaults.standard.set(version, forKey: "MoraPay_ActiveModelVersion")
                completion(true)
            } catch {
                completion(false)
            }
        }
        task.resume()
    }
}
