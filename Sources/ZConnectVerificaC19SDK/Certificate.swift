//
//  Certificate.swift
//  ZConnectVerifierSDK
//
//  Created by SALMAT on 10/11/21.
//

import Foundation
import SwiftDGC

public class Certificate {
    internal let cert: HCert?

    public required init?(from payload: String?) {
        guard let payload = payload else { return nil }
        cert = HCert(from: payload)
    }
    
    public var payload: String? { cert?.fullPayloadString }
    
    public var firstName: String? { cert?.firstName }
    
    public var lastName: String? { cert?.lastName }
    
    public var dateOfBirth: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: cert?.birthDate ?? "")
    }
}
