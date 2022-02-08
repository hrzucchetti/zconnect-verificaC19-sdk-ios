/*
 *  license-start
 *
 *  Copyright (C) 2021 Zucchetti S.p.a and all other contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

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
    private var completionQueue: DispatchQueue = .main
    private var completion: ((SyncResult) -> Void)?
    public init(){
    }
    /**
     Synchronizes data from backend
     Ensure you are calling this method at least every 24 hours to keep rules settings and signature keys up to date
     - Parameter completionQueue: The DispatchQueue where the completion will be executed
     - Parameter completion: Completion method that will be called with a result when synchronization ends
     */
    public func sync(completionQueue: DispatchQueue = .main, completion: @escaping (SyncResult) -> Void) {
        self.completionQueue = completionQueue
        self.completion = completion
        guard !isSdkVersionOutdated() else {
            completionQueue.async {
                completion(.sdkOutdated)
            }
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
            GatewayConnection.shared.update { [weak self] errorString in
                if let error = errorString {
                    self?.completionQueue.async {
                        completion(.error(error: error))
                    }
                    return
                }
                CRLDataStorage.initialize {
                    CRLSynchronizationManager.shared.initialize(delegate: self)
                }
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

extension DataSynchronizer : CRLSynchronizationDelegate {
    func statusDidChange(with result: CRLSynchronizationManager.Result) {
        switch result {
            case .downloading:
                break
            case .downloadReady, .paused:
                CRLSynchronizationManager.shared.download()
            case .completed:
                LocalData.sharedInstance.lastFetch = Date()
                LocalData.sharedInstance.save()
                completionQueue.async {
                    [weak self] in
                    self?.completion?(.updated)
                }
            case .error, .statusNetworkError:
                completionQueue.async {
                    [weak self] in
                    self?.completion?(.error(error: ""))
                }
        }
    }
}
