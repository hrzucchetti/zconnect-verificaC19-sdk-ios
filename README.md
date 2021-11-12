<h1 align="left">
    ZConnect COVID Certificate Verifier SDK - iOS
</h1>

<p align="left">
    <a href="/../../commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/hrzucchetti/zconnect-verificaC19-sdk-ios?style=flat"></a>
    <a href="/../../issues" title="Open Issues"><img src="https://img.shields.io/github/issues/hrzucchetti/zconnect-verificaC19-sdk-ios?style=flat"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=flat"></a>
</p>

## About SDK

This repository contains the source code of *ZConnectVerificaC19SDK*, SDK for iOS written in Swift based on [official it-dgc-verificac19-sdk-android](https://github.com/ministero-salute/it-dgc-verificac19-sdk-android). The repository is forked from the [official VerificaC19 App - iOS](https://github.com/ministero-salute/it-dgc-verificaC19-ios).

The SDK allows verifying DCCs using public keys from Italy backend servers. Offline verification is supported, if the latest public keys are present in the app's key store. Consequently, once up-to-date keys have been downloaded, the verification works without active internet connection.

## Development

### Prerequisites

- You need a Mac to run Xcode.
- Xcode 12.5+ is used for our builds. The OS requirement is macOS 11.0+.
- To install development apps on physical iPhones, you need an Apple Developer account.
- Service Endpoints:
  - This Library talks to the endpoint: `https://get.dgc.gov.it/v1/dgc/` to retrieve kids, public keys, settings and medical rules for prod configuration,
  - To get QR Codes for testing, you might want to check out `https://dgc.a-sit.at/ehn/testsuite`.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding ZConnectVerificaC19SDK as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/hrzucchetti/zconnect-verificaC19-sdk-ios.git", .branch("develop"))
]
```
### Usage
```swift
    //use synchronizer to fetch data from backend
    let synchronizer = DataSynchronizer()
    synchronizer.sync { result in
        switch result {
        case .updated:
            break
        case .sdkOutdated:
            break
        case .error(let error):
            break
        }
    }
    
    //use certificate to get a simplified model of certificate content
    let certificate: Certificate? = Certificate(from: qrContent)

    //use validator to validate a certificate
    let validator = CertificateValidator(payload: qrCodeContent)
    //or use this initializer 
    let validator = CertificateValidator(certificate: certificate!)
    
    validator.validate(onSuccessHandler: { status in
        switch status {
        case .valid,.validPartially:
            //is valid
            break
        case .notValid, .notValidYet, .notGreenPass:
            //not is valid
            break
        }
    })
```
## Dependencies

The following dependencies are used in the project  by the verifier app and the core app and are imported as Swift Packages:
- **[SwiftDGC](https://github.com/eu-digital-green-certificates/dgca-app-core-ios).** Eurpean core library that contains business logic to decode data from QR code payload and performs technical validations (i.e. correct signature verification, signature expiration verification, correct payload format etc).
- **[Alamofire](https://github.com/Alamofire/Alamofire).** Library used for networking.
- **[JSONSchema](https://github.com/eu-digital-green-certificates/JSONSchema.swift).** Library used by core module to validate DCC payload JSON schema.
- **[SwiftCBOR](https://github.com/eu-digital-green-certificates/SwiftCBOR).** Library used by core module for CBOR specification implementation.
- **[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON).** Library used by core module to translate data from JSON format.

## Support and feedback

The following channels are available for discussions, feedback, and support requests:

| Type               | Channel                                                                                                                                                                          |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Issues**         | <a href="/../../issues" title="Open Issues"><img src="https://img.shields.io/github/issues/hrzucchetti/zconnect-verificaC19-sdk-ios?style=flat"></a>                  |

## How to contribute

Contribution and feedback is encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](./CONTRIBUTING.md). By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Contributors

Our commitment to open source means that we are enabling -in fact encouraging- all interested parties to contribute and become part of its developer community.

## Licensing

See the [NOTICE](./NOTICE) for all copyright and licensing details.

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
