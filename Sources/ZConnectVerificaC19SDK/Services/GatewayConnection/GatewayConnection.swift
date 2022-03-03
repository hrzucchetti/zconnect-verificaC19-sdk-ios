//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-verifier-app-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//  
//  GatewayConnection.swift
//  DGCAVerifier
//  
//  Created by Yannick Spreen on 4/24/21.
//  

import Foundation
import Alamofire
import SwiftDGC
import SwiftyJSON

extension Bundle {
    func infoForKey(_ key: String, inFile file: String) -> String {
        let path = path(forResource: file, ofType: "plist")
        guard let path = path else { return "" }
        return NSDictionary(contentsOfFile: path)?[key] as? String ?? ""
    }
#if !SWIFT_PACKAGE
    static let module = Bundle(for: GatewayConnection.self)
#endif
}

class GatewayConnection {
    let baseUrl: String
    let session: Session
    var timer: Timer?
    let serialQueue = DispatchQueue(label: "serialQueue", qos: .background)
    //private let certificateFilename: String
    //private let certificateEvaluator: String
    
    static let shared = GatewayConnection()
    
    let sdkUserAgent : HTTPHeader = .userAgent("\(SDKConfig.SDKName)-\(SDKConfig.SDKTechnology)/\(SDKConfig.SDKVersion)")
    
    private init() {
        baseUrl = SDKConfig.baseUrl
        /*certificateFilename = SDKConfig.certificateFilename
        certificateEvaluator = SDKConfig.certificateEvaluator
        
        // Init certificate for pinning
        let filePath = Bundle.module.path(forResource: certificateFilename, ofType: nil)!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
                    
        // Init session
        let evaluators = [certificateEvaluator: PinnedCertificatesTrustEvaluator(certificates: [certificate])]
//        session = AF
         session = Session(serverTrustManager: ServerTrustManager(evaluators: evaluators))*/
        let configuration = URLSessionConfiguration.af.default
        configuration.headers.add(sdkUserAgent)
        session = Session(configuration: configuration)
    }

    func initialize(completion: (()->())? = nil) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            self.trigger(completion: completion)
        }
        timer?.tolerance = 5.0
        self.trigger(completion: completion)
    }
    
    func trigger(completion: (()->())? = nil) {
        guard LocalData.sharedInstance.lastFetch.timeIntervalSinceNow < -24 * 60 * 60 else {
            return
        }
        completion?()
    }

}
