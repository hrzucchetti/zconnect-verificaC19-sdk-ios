/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
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

//
//  GatewayConnection+Settings.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation
import SwiftDGC

extension GatewayConnection {
    
    private var settingsUrl: String { baseUrl + "settings" }
    
    func settings(completion: ((String?) -> Void)? = nil) {
        getSettings { settings in
            guard let settings = settings else {
                completion?("server.error.generic.error".localized)
                return
            }
            
            for setting in settings {
                SettingDataStorage.sharedInstance.addOrUpdateSettings(setting)
            }
            SettingDataStorage.sharedInstance.save()
            
            completion?(nil)
        }
    }
    
    private func getSettings(completion: (([Setting]?) -> Void)?) {
        session.request(settingsUrl).response(queue: serialQueue) {
            let decoder = JSONDecoder()
            let data = try? decoder.decode([Setting].self, from: $0.data ?? .init())
            guard let settings = data else {
                completion?(nil)
                return
            }
            completion?(settings)
        }
    }

}
