//
//  HealthKitSetupAssistant.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 6/28/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    
    static let defaultCharacteristicsTypes: [HKCharacteristicTypeIdentifier] = [
        .dateOfBirth,
        .bloodType,
        .biologicalSex,
    ]
    
    static let defaultQuantityTypes: [HKQuantityTypeIdentifier] = [
        .bodyMassIndex,
        .height,
        .heartRate,
        .bodyMass,
    ]
    
    static let defaultHKObjectTypes : [HKObjectType] = [
        HKObjectType.workoutType(),
        HKSeriesType.workoutRoute(),
    ]
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(
        characteristicsTypes: [HKCharacteristicTypeIdentifier] = defaultCharacteristicsTypes,
        quantityTypes: [HKQuantityTypeIdentifier] = defaultQuantityTypes,
        otherObjectTypes: [HKObjectType] = defaultHKObjectTypes,
        completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        var healthKitTypesToRead = Set<HKObjectType>()
        
        for characteristic in characteristicsTypes {
            guard let characteristicType = HKObjectType.characteristicType(forIdentifier: characteristic) else {
                return completion(false, HealthkitSetupError.dataTypeNotAvailable)
            }
            healthKitTypesToRead.insert(characteristicType)
        }
        
        for quantity in quantityTypes {
            guard let quantityType = HKObjectType.quantityType(forIdentifier: quantity) else {
                return completion(false, HealthkitSetupError.dataTypeNotAvailable)
            }
            healthKitTypesToRead.insert(quantityType)
        }
        
        for other in otherObjectTypes {
            healthKitTypesToRead.insert(other)
        }
        
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}
