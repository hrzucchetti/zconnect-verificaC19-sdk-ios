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

struct SDKConfig {
    static let SDKName = "ZConnectVerificaC19SDK"
    static let SDKTechnology = "swift"
    static let baseUrl = "https://get.dgc.gov.it/v1/dgc/"
    static let certificateFilename = "get-dgc-gov-it.der"
    static let certificateEvaluator = "get.dgc.gov.it"
    static let SDKVersion = "1.1.9"
}
