//
//  SdkScanMode.swift
//  ZConnectVerificaC19
//
//  Created by SALMAT on 08/03/22.
//

import Foundation

public enum ScanMode {
    case scanModeBooster
    case scanModeReinforced
    case scanModeBase
}

extension ScanMode {
    private static let scanModeMapping: [ScanMode: ScanModeInternal] = [
        .scanModeBooster : .booster,
        .scanModeBase : .base,
        .scanModeReinforced : .reinforced
    ]
    
    internal var internalMode: ScanModeInternal? {
        ScanMode.scanModeMapping[self]
    }
    
    var description: String? {
        internalMode?.scanModeDescription
    }
}
