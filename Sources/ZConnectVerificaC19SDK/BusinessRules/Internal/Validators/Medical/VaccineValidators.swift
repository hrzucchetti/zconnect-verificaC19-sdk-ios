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
//  VaccineValidators.swift
//  Verifier
//
//  Created by Ludovico Girolimini on 01/02/22.
//

import Foundation
import SwiftDGC

struct VaccinationInfo {
    let currentDoses: Int
    let totalDoses: Int
    let medicalProduct: String
    let vaccineDate: Date
    let countryCode: String
    let patientAge: Int?
    
    var patientOver50: Bool {
        guard let age = patientAge else { return false }
        return age >= 50
    }
    
    var isIT: Bool { self.countryCode.uppercased() == Constants.ItalyCountryCode }
    var isJJ: Bool { self.medicalProduct == Constants.JeJVacineCode }
    
    var isJJBooster: Bool { self.isJJ && (self.currentDoses >= Constants.jjBoosterMinimumDosesNumber) }
    var isNonJJBooster: Bool { !self.isJJ && (self.currentDoses >= Constants.boosterMinimumDosesNumber) }
    
    var isCurrentDoseIncomplete: Bool { self.currentDoses < self.totalDoses }
    var isCurrentDoseComplete: Bool { self.currentDoses == self.totalDoses && !self.isJJBooster && !self.isNonJJBooster }
    var isCurrentDoseBooster: Bool { (self.currentDoses > self.totalDoses) || (isJJBooster || self.isNonJJBooster) }
    
    var isEMAProduct: Bool {
        let emaAllProducts = ["EU/1/20/1525", "EU/1/20/1507", "EU/1/20/1528", "EU/1/21/1529", "Covishield", "R-COVI", "Covid-19-recombinant"]
        if emaAllProducts.contains(medicalProduct) // (Sputnik-V solo se emesso da San marino ovvero co="SM")
            || (countryCode == Constants.sanMarinoCode && medicalProduct == Constants.SputnikVacineCode) {
            return true
        }
        else {
            return false
        }
    }
    
}


class VaccineBaseValidator: DGCValidator {
            
    typealias Validator = VaccineBaseValidator
    
    private var allowedVaccinationInCountry: [String: [String]] {
        [Constants.SputnikVacineCode: [Constants.sanMarinoCode]]
    }
    
    func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        return checkVaccinationInterval(vaccinationInfo)
    }
    
    func getVaccinationData(_ hcert: HCert) -> VaccinationInfo? {
        guard let currentDoses = hcert.currentDosesNumber, currentDoses > 0 else { return nil }
        guard let totalDoses = hcert.totalDosesNumber, totalDoses > 0 else { return nil }
        guard let vaccineDate = hcert.vaccineDate?.toVaccineDate else { return nil }
        guard let medicalProduct = hcert.medicalProduct else { return nil }
        guard isValid(for: medicalProduct) else { return nil }
        guard let countryCode = hcert.countryCode else { return nil }
        guard isAllowedVaccination(for: medicalProduct, fromCountryWithCode: countryCode) else { return nil }
        
        return VaccinationInfo(currentDoses: currentDoses, totalDoses: totalDoses, medicalProduct: medicalProduct, vaccineDate: vaccineDate, countryCode: countryCode, patientAge: hcert.age)
    }
    
    func checkVaccinationInterval(_ vaccinationInfo: VaccinationInfo) -> Status {
       
        guard let start = getStartDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        guard let end = getEndDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        guard let ext = getExtensionDays(vaccinationInfo: vaccinationInfo) else { return .notValid }
        
        
        guard let validityStart = vaccinationInfo.vaccineDate.add(start, ofType: .day) else { return .notValid }
        guard let validityEnd = vaccinationInfo.vaccineDate.add(end, ofType: .day)?.startOfDay else { return .notValid }
        guard let validityExt = vaccinationInfo.vaccineDate.add(ext, ofType: .day)?.startOfDay else { return .notValid }
        
        
        guard let currentDate = Date.startOfDay else { return .notValid }
        
        // J&J booster is immediately valid
        let fromDate = vaccinationInfo.isJJBooster ? vaccinationInfo.vaccineDate : validityStart
        
        return Validator.validate(currentDate, from: fromDate, to: validityEnd, extendedTo: validityExt)
    }
    
    private func isAllowedVaccination(for medicalProduct: String, fromCountryWithCode countryCode: String) -> Bool {
        if let allowedCountries = allowedVaccinationInCountry[medicalProduct] {
            return allowedCountries.contains(countryCode)
        }
        return true
    }
    
    private func isValid(for medicalProduct: String) -> Bool {
        // Vaccine code not included in settings -> not a valid vaccine for Italy
        let name = Constants.vaccineCompleteEndDays
        return getValue(for: name, type: medicalProduct) != nil
    }
        
    public func startDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = vaccinationInfo.isIT ? Constants.vaccineBoosterStartDays_IT : Constants.vaccineBoosterStartDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func startDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineIncompleteStartDays
        return self.getValue(for: setting)?.intValue
    }
    
    public func startDaysForJJ(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteStartDays
        return self.getValue(for: setting, type: vaccinationInfo.medicalProduct)?.intValue
    }
    
    public func startDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = vaccinationInfo.isIT ? Constants.vaccineCompleteStartDays_IT : Constants.vaccineCompleteStartDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func getStartDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return startDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return startDaysForIncompleteDose(vaccinationInfo)
        }
    
        if vaccinationInfo.isJJ {
            return startDaysForJJ(vaccinationInfo)
        }
        
        return startDaysForCompleteDose(vaccinationInfo)
    }
    
    public func endDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = vaccinationInfo.isIT ? Constants.vaccineBoosterEndDays_IT : Constants.vaccineBoosterEndDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func endDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return self.getValue(for: Constants.vaccineIncompleteEndDays, type: vaccinationInfo.medicalProduct)?.intValue
    }
    
    public func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = vaccinationInfo.isIT ? Constants.vaccineCompleteEndDays_IT : Constants.vaccineCompleteEndDays_NOT_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public func getEndDays(vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isCurrentDoseBooster {
            return endDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return endDaysForIncompleteDose(vaccinationInfo)
        }
    
        return endDaysForCompleteDose(vaccinationInfo)
    }
    
    
    public func extDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForBoosterDose(vaccinationInfo)
    }
    
    public func extDaysForIncompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForIncompleteDose(vaccinationInfo)
    }
    
    public func extDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return endDaysForCompleteDose(vaccinationInfo)
    }
    

    public func getExtensionDays(vaccinationInfo: VaccinationInfo) -> Int? {
        
        if vaccinationInfo.isCurrentDoseBooster {
            return extDaysForBoosterDose(vaccinationInfo)
        }
        
        if vaccinationInfo.isCurrentDoseIncomplete {
            return extDaysForIncompleteDose(vaccinationInfo)
        }
    
        return extDaysForCompleteDose(vaccinationInfo)
        
    }
    
    
    public func getValue(for name: String, type: String) -> String? {
        return LocalData.getSetting(from: name, type: type)
    }
    
    public func getValue(for name: String) -> String? {
        return LocalData.getSetting(from: name)
    }
    
}


class VaccineReinforcedValidator: VaccineBaseValidator {
    
    public override func startDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return self.getValue(for: Constants.vaccineBoosterStartDays_IT)?.intValue
    }
    
    public override func startDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return getValue(for: Constants.vaccineCompleteStartDays_IT)?.intValue
    }
    
    public override func endDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return getValue(for: Constants.vaccineBoosterEndDays_IT)?.intValue
        } else {
            return vaccinationInfo.isEMAProduct ? getValue(for: Constants.vaccineBoosterEndDays_NOT_IT)?.intValue : 0
        }
    }
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return getValue(for: Constants.vaccineCompleteEndDays_IT)?.intValue
        } else {
            return vaccinationInfo.isEMAProduct ? getValue(for: Constants.vaccineCompleteEndDays_EMA)?.intValue : 0
        }
    }
 
    public override func extDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return endDaysForCompleteDose(vaccinationInfo)
        } else {
            return getValue(for: Constants.vaccineCompleteExtendedDays_EMA)?.intValue
        }
    }
    
    public override func extDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return endDaysForBoosterDose(vaccinationInfo)
        } else {
            return getValue(for: Constants.vaccineBoosterEndDays_NOT_IT)?.intValue
        }
    }
    
}


class VaccineBoosterValidator: VaccineReinforcedValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        let result = super.checkVaccinationInterval(vaccinationInfo)
        
        guard result == .valid else { return result }
        return checkBooster(vaccinationInfo)
    }
    
    private func checkBooster(_ vaccinationInfo: VaccinationInfo) -> Status {
        if vaccinationInfo.isCurrentDoseBooster { return . valid }
        return vaccinationInfo.isCurrentDoseComplete ? .verificationIsNeeded : .notValid
    }
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return getValue(for: Constants.vaccineCompleteEndDays_IT)?.intValue
        } else {
            return startDaysForCompleteDose(vaccinationInfo)
        }
    }
 
    public override func extDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if vaccinationInfo.isIT {
            return endDaysForCompleteDose(vaccinationInfo)
        } else {
            return getValue(for: Constants.vaccineCompleteEndDays_EMA)?.intValue
        }
    }
    
}

class VaccineSchoolValidator: VaccineBaseValidator {
	
	override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
		let result = super.checkVaccinationInterval(vaccinationInfo)
		
		guard result == .valid else { return result }
		return vaccinationInfo.isCurrentDoseIncomplete ? .notValid : .valid
	}
    
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        return getValue(for: Constants.vaccineSchoolEndDays)?.intValue
    }
    
}


class VaccineWorkValidator: VaccineReinforcedValidator {
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        if (vaccinationInfo.isIT) {
            return super.endDaysForCompleteDose(vaccinationInfo)
        } else {
            guard !vaccinationInfo.patientOver50 else { return super.endDaysForCompleteDose(vaccinationInfo) }
            return getValue(for: Constants.vaccineCompleteEndDays_NOT_IT)?.intValue
        }
    }
    
}


class VaccineItalyEntryValidator: VaccineBaseValidator {
    
    override func validate(hcert: HCert) -> Status {
        guard let vaccinationInfo = getVaccinationData(hcert) else { return .notValid }
        let result = super.checkVaccinationInterval(vaccinationInfo)
        guard result == .valid else { return result }
        return .notValid
    }
    
    public override func endDaysForCompleteDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineCompleteEndDays_IT
        return self.getValue(for: setting)?.intValue
    }
    
    public override func endDaysForBoosterDose(_ vaccinationInfo: VaccinationInfo) -> Int? {
        let setting = Constants.vaccineBoosterEndDays_IT
        return self.getValue(for: setting)?.intValue
    }
}
