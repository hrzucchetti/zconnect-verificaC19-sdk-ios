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

public struct InvalidScanModeError : Error {
    
}

public class CertificateValidator {
    
    private let certificate: Certificate?
    
    public init?(payload: String) {
        certificate = Certificate(from: payload)
    }
    
    public init(certificate: Certificate) {
        self.certificate = certificate
    }
    
    public func validate(scanMode: ScanMode = .scanModeBase, onSuccessHandler: @escaping (Status) -> Void, onFailureHandler: ((Error) -> Void)? = nil) {
        guard let certificate = certificate else {
            onFailureHandler?(InvalidCertificateError())
            return
        }
        guard !DataSynchronizer().isSdkVersionOutdated() else {
            onFailureHandler?(SdkOutdatedError())
            return
        }
        guard let mode = scanMode.internalMode else {
            onFailureHandler?(InvalidScanModeError())
            return
        }
        guard let hCert = certificate.cert else {
            onSuccessHandler(.notGreenPass)
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            if let validator = DGCValidatorBuilder().scanMode(mode).build(hCert: hCert) {
                let status = validator.validate(hcert: hCert)
            
                var resolvedStatus: Status = .notGreenPass
                switch status {
                case .valid:
                    resolvedStatus = .valid
                case .notValid, .notValidYet, .revokedGreenPass, .expired:
                    resolvedStatus = .notValid
                case .notGreenPass:
                    resolvedStatus = .notGreenPass
                case .verificationIsNeeded:
                    resolvedStatus = .verificationIsNeeded
                }
                DispatchQueue.main.async {
                    onSuccessHandler(resolvedStatus)
                }
            }
        }
    }
    
    @available(*, deprecated, message: "Use validate with scanMode function instead")
    public func validate(onSuccessHandler: @escaping (Status) -> Void, onFailureHandler: ((Error) -> Void)? = nil)
    {
        guard let scanMode = CertificateValidator.defaultScanMode else {
            onFailureHandler?(InvalidScanModeError())
            return
        }
        validate(scanMode: scanMode, onSuccessHandler: onSuccessHandler, onFailureHandler: onFailureHandler)
    }
}

extension CertificateValidator {
    private static var defaultScanMode: ScanMode?
    
    @available(*, deprecated, message: "Use validate with scanMode function instead")
    public static func setScanMode(_ scanMode: ScanMode) {
        defaultScanMode = scanMode
    }
    
    @available(*, deprecated, message: "Use setScanMode function instead")
    public static func setScanMode2GActive(_ scanMode2GActive: Bool) {
        setScanMode(.scanModeBase)
    }
}
