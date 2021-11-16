//
//  DataSynchronizer.swift
//  ZConnectVerifierSDK
//
//  Created by SALMAT on 10/11/21.
//

import Foundation

public enum SyncResult
{
    case updated
    case sdkOutdated
    case error(error: String)
}

public struct SdkOutdatedError : Error {
    
}

public class DataSynchronizer {
    public init(){
        load(completion: { _ in })
    }
    
    public func sync(completion: @escaping (SyncResult) -> Void)
    {
        guard !isSdkVersionOutdated() else {
            completion(.sdkOutdated)
            return
        }
        GatewayConnection.shared.initialize { [weak self] in self?.load(completion: completion) }
    }
    
    public func getLastUpdate() -> Date? {
        let lastFetch = LocalData.sharedInstance.lastFetch
        return lastFetch.timeIntervalSince1970 > 0 ? lastFetch : nil
    }
    
    private func load(completion: @escaping (SyncResult) -> Void) {
        SettingDataStorage.initialize {
            GatewayConnection.shared.settings { _ in }
        }
        LocalData.initialize {
            GatewayConnection.shared.update { errorString in
                if let error = errorString {
                    completion(.error(error: error))
                    return
                }
                completion(.updated)
            }
        }
    }
    
    public func isSdkVersionOutdated() -> Bool {
        guard let minVersion = minSdkVersion() else { return false }
        return currentSdkVersion().compare(minVersion, options: .numeric) == .orderedAscending
    }
    
    public func currentSdkVersion() -> String {
        return SDKConfig.SDKVersion
    }
    
    private func minSdkVersion() -> String? {
        return SettingDataStorage
            .sharedInstance
            .settings
            .first(where: { $0.name == "sdk" })?
            .value
    }
}
