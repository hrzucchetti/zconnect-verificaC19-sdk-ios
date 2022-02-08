//
//  ScanMode.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation


enum ScanModeInternal: String, CaseIterable {
    case base = "scanMode3G"
    case italyEntry = "scanModeItalyEntry"
    case reinforced = "scanMode2G"
    case booster = "scanModeBooster"
    case school = "scanModeSchool"
    case work = "scanMode50"
}
