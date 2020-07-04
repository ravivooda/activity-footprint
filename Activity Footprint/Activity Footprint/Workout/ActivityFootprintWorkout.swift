//
//  ActivityFootprintWorkout.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 7/2/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import Foundation
import MapKit
import HealthKit

typealias WorkoutRouteProgressBlock = (LoadingState, HKWorkout) -> Void
typealias WorkoutRoutesCompletionBlock = (Error?) -> Void
typealias WorkoutRouteLocationsCompletionBlock = (Error?) -> Void

enum WorkoutRoutesLoadingError: Error {
    case castingError
}

enum WorkoutLocationsLoadingError: Error {
    case castingError
}

class ActivityFootprintWorkout {
    let workout : HKWorkout
    let store: HKHealthStore
    lazy var routes = [ActivityFootprintWorkoutRoute]()
    
    public init(workout:HKWorkout, store: HKHealthStore) {
        self.workout = workout
        self.store = store
    }
    
    func loadRoutes(
        completion: @escaping WorkoutRoutesCompletionBlock
    ) -> Void {
        let workoutPredicate = HKQuery.predicateForObjects(from: self.workout)
        
        let routeQuery = HKAnchoredObjectQuery(
            type: HKSeriesType.workoutRoute(),
            predicate: workoutPredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { (query, routeSamples, deletedObjects, anchor, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    return completion(error)
                }
                
                guard let routeSamples = routeSamples as? [HKWorkoutRoute] else {
                    return completion(WorkoutRoutesLoadingError.castingError)
                }
                
                var routes = [ActivityFootprintWorkoutRoute]()
                for rs in routeSamples {
                    routes.append(ActivityFootprintWorkoutRoute(route: rs, store: self.store))
                }
                self.routes = routes
                
                completion(nil)
            }
        }
        
        self.store.execute(routeQuery)
    }
}

class ActivityFootprintWorkoutRoute {
    let route : HKWorkoutRoute
    let store: HKHealthStore
    lazy var data = ActivityFootprintWorkoutRouteData(locations: [])
    
    internal init(route: HKWorkoutRoute, store: HKHealthStore) {
        self.route = route
        self.store = store
    }
    
    func loadLocationData(
        completion: @escaping WorkoutRouteLocationsCompletionBlock
    ) {
        self.data.locations = []
        
        let query = HKWorkoutRouteQuery(route: self.route) { (query, locationsOrNil, done, errorOrNil) in
            DispatchQueue.main.async {
                guard errorOrNil == nil else {
                    return completion(errorOrNil)
                }
                
                guard let locations = locationsOrNil else {
                    return completion(WorkoutLocationsLoadingError.castingError)
                }
                
                self.data.locations.append(contentsOf: locations)
                
                if done {
                    return completion(nil)
                }
            }
        }
        self.store.execute(query)
    }
}

class ActivityFootprintWorkoutRouteData {
    var locations: [CLLocation]
    
    internal init(locations: [CLLocation]) {
        self.locations = locations
    }
}
