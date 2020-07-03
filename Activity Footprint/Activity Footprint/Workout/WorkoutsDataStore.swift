//
//  WorkoutsDataStore.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 6/28/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import HealthKit

import HealthKit

class WorkoutDataStore {
    class func loadWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
        let store = HKHealthStore()
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate])
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: compound, limit: 10, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKWorkout], error == nil else {
                    completion(nil, error)
                    return
                }
                
                completion(samples, nil)
                
                for sample in samples {
                    let runningObjectQuery = HKQuery.predicateForObjects(from: sample)

                    let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
                        
                        guard let samples = samples, error == nil else {
                            // Handle any errors here.
                            print("Error occurred in handling workout route request \(sample), error: \(error)")
                            return
                        }
                        
                        // Process the initial route data here.
                        print("For sample \(sample), route data is \(samples)")
                    }
                    
                    store.execute(routeQuery)
                }
            }
        }
        
        store.execute(query)
    }
}
