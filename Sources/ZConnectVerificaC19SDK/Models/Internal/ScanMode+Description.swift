//
//  ScanMode+Description.swift
//  ZConnectVerificaC19
//
//  Created by SALMAT on 08/03/22.
//

import Foundation

extension ScanModeInternal {
    var scanModeDescription: String? {
        switch self {
        case .base:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescription3G)
        case .italyEntry:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescriptionItalyEntry)
        case .reinforced:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescription2G)
        case .booster:
            return SettingDataStorage.sharedInstance.getFirstSetting(withName: Constants.scanModeDescriptionBooster)
        }
    }
}
