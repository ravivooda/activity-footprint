//
//  ViewController.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 6/28/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    fileprivate func loadWorkoutsAndData() {
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            guard error == nil else {
                print("Error occurred in accessing health kit: \(error!)")
                return
            }
            
            guard success else {
                print("Does not have access to health kit")
                return
            }
            
            WorkoutDataStore.shared().loadWorkouts(
                interestedActivities: [
                    .running,
                    .cycling,
                ], progressTracker: { (state, item) in
                    print(state)
                    print(String(describing: item))
            }) { (workouts, error) in
                guard error == nil, let workouts = workouts else {
                    print("Error occurred while reading health data \(error!)")
                    return
                }
                
                guard workouts.count != 0 else {
                    print("Empty workouts!!!")
                    return
                }
                
                print("Workouts: \(workouts)")
                
                for workout in workouts {
                    workout.loadRoutes { (error) in
                        guard error == nil else {
                            print("Error ocurred in fetching routes for workout: \(workout), error: \(error!)")
                            return
                        }
                        
                        print("Successfully loaded routes for workout: \(workout)")
                        
                        for workoutroute in workout.routes {
                            workoutroute.loadLocationData { (error) in
                                guard error == nil else {
                                    print("Error ocurred in fetching route data for route: \(workoutroute) in workout: \(workout), error: \(error!)")
                                    return
                                }
                                
                                print("Successfully loaded route information")
                            }
                        }
                        
                        print("Successfully loaded all route data informations for the workout: \(workout)")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWorkoutsAndData()
    }
}
