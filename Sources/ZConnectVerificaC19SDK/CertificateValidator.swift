//
//  Validator.swift
//  ZConnectVerifierSDK
//
//  Created by SALMAT on 10/11/21.
//

import Foundation
import SwiftDGC

public struct InvalidCertificateError : Error {
    
}

public class CertificateValidator {
    private let certificate: Certificate?
    
    public init?(payload: String) {
        certificate = Certificate(from: payload)
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
