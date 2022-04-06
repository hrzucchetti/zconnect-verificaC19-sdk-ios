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

public class Certificate {
    internal let cert: HCert?

    public required init?(from payload: String?) {
        guard let payload = payload else { return nil }
        cert = HCert(from: payload)
    }
    
    public var payload: String? { cert?.fullPayloadString }
    
    public var firstName: String? { cert?.firstName }
    
    public var lastName: String? { cert?.lastName }

    public var standardizedFirstName: String? { cert?.standardizedFirstName }
    
    public var standardizedLastName: String? { cert?.standardizedLastName }

    public var fullName: String? { cert?.fullName }
    
    public var fullName2: String? { cert?.name }
    
    public var dateOfBirth: Date? { cert?.birthDate }
}
