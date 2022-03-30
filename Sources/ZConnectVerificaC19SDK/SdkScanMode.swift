//
//  SdkScanMode.swift
//  ZConnectVerificaC19
//
//  Created by SALMAT on 08/03/22.
//

import Foundation

public enum ScanMode {
    case scanMode3G
    case scanMode2G
    case scanModeBooster
    case scanModeWork
    case scanModeItalyEntry
    case scanModeReinforced
    case scanModeBase
}

extension ScanMode {
    private static let scanModeMapping: [ScanMode: ScanModeInternal] = [
        .scanMode2G : .reinforced,
        .scanMode3G : .base,
        .scanModeBooster : .booster,
        .scanModeWork : .work,
        .scanModeItalyEntry : .italyEntry,
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
