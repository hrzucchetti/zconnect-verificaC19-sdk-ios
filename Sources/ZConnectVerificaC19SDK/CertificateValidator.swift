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
import SwiftDGC

public struct InvalidCertificateError : Error {
    
}

public class CertificateValidator {
    private let certificate: Certificate?
    
    public static func setScanMode2GActive(scanMode2GActive: Bool) {
        Store.set(scanMode2GActive, for: .isScanMode2G)
    }
    
    public init?(payload: String) {
        certificate = Certificate(from: payload)
    }
    
    public init(certificate: Certificate) {
        self.certificate = certificate
    }
    
    public func validate(onSuccessHandler: @escaping (Status) -> Void, onFailureHandler: ((Error) -> Void)? = nil)
    {
        guard let certificate = certificate else {
            onFailureHandler?(InvalidCertificateError())
            return
        }

        guard !DataSynchronizer().isSdkVersionOutdated() else {
            onFailureHandler?(SdkOutdatedError())
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let status = RulesValidator.getStatus(from: certificate.cert)
            DispatchQueue.main.async {
                onSuccessHandler(status)
            }
        }
    }
}
