//
//  WorkoutsDataStore.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 6/28/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import HealthKit
import MapKit

enum LoadingState {
    case starting
    case started
    case loading
    case loaded
}

typealias ProgressClosureBlock = (LoadingState, HKWorkoutActivityType) -> Void
typealias CompletionClosureBlock = ([ActivityFootprintWorkout]?, Error?) -> Void

class WorkoutDataStore {
    private let store = HKHealthStore()
    
    private init() {}
    
    private static let instance = WorkoutDataStore()
    class func shared() -> WorkoutDataStore {
        return instance
    }
    
    func loadWorkouts(
        interestedActivities: [HKWorkoutActivityType],
        sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false),
        limit: uint = 0,
        progressTracker: ProgressClosureBlock? = nil,
        completion: @escaping CompletionClosureBlock
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            var workouts = [ActivityFootprintWorkout]()
            
            let lockGroup = DispatchGroup()
            
            for interestedActivity in interestedActivities {
                guard let self = self else { return }
                
                lockGroup.enter()
                
                let workoutPredicate = HKQuery.predicateForWorkouts(with: interestedActivity)
                let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate])
                
                let currentInterestedActivity = interestedActivity
                
                let query =
                    HKSampleQuery(
                        sampleType: .workoutType(),
                        predicate: compound,
                        limit: Int(limit),
                        sortDescriptors: [sortDescriptor]
                    ) { (query, samples, error) in
                        DispatchQueue.main.sync {
                            guard let samples = samples as? [HKWorkout], error == nil else {
                                completion(nil, error)
                                return
                            }
                            
                            for w in samples {
                                workouts.append(ActivityFootprintWorkout(workout: w, store: self.store))
                            }
                            
                            progressTracker?(.loaded, currentInterestedActivity)
                            lockGroup.leave()
                        }
                }
                self.store.execute(query)
            }
            lockGroup.notify(queue: .main) {
                completion(workouts, nil)
            }
        }
    }
}

extension HKWorkoutActivityType: CustomStringConvertible {
    public var description: String {
        return "Workout Type \(rawValue)"
    }
}

/*
 for sample in samples {
 let runningObjectQuery = HKQuery.predicateForObjects(from: sample)
 
 let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { (query, routeSamples, deletedObjects, anchor, error) in
 
 guard let routeSamples = routeSamples as? [HKWorkoutRoute], error == nil else {
 // Handle any errors here.
 print("Error occurred in handling workout route request \(sample), error: \(error)")
 return
 }
 
 guard routeSamples.count > 0 else {
 print("Empty routes")
 return
 }
 
 // Process the initial route data here.
 print("For sample \(sample), route data is \(routeSamples)")
 for route in routeSamples {
 // Create the route query.
 let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
 
 // This block may be called multiple times.
 
 if let error = errorOrNil {
 // Handle any errors here.
 return
 }
 
 guard let locations = locationsOrNil else {
 fatalError("*** Invalid State: This can only fail if there was an error. ***")
 }
 
 // Do something with this batch of location data.
 
 if done {
 // The query returned all the location data associated with the route.
 // Do something with the complete data set.
 }
 
 // You can stop the query by calling:
 // store.stop(query)
 
 }
 self.store.execute(query)
 }
 }
 
 self.store.execute(routeQuery)
 }
 */
