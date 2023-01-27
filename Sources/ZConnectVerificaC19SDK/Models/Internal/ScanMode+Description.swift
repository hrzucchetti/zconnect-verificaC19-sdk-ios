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
        }
    }
}
