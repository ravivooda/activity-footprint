//
//  WorkoutsLoadingViewController.swift
//  Activity Footprint
//
//  Created by Ravi Vooda on 7/4/20.
//  Copyright © 2020 Ravi Vooda. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutsLoadingViewController: UIViewController {
    let interestedActivities: [HKWorkoutActivityType] = [
        .running,
        .cycling,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.loadWorkouts()
    }
    
    fileprivate func loadWorkoutData(_ workoutroute: ActivityFootprintWorkoutRoute) {
        workoutroute.loadLocationData { (error) in
            guard error == nil else {
                print("Error ocurred in fetching route data for route: \(workoutroute), error: \(error!)")
                return
            }
            
            print("Successfully loaded route information")
        }
    }
    
    fileprivate func loadWorkoutRoutes(_ workout: ActivityFootprintWorkout) {
        workout.loadRoutes { (error) in
            guard error == nil else {
                print("Error ocurred in fetching routes for workout: \(workout), error: \(error!)")
                return
            }
            
            print("Successfully loaded routes for workout: \(workout)")
            
            for workoutroute in workout.routes {
                self.loadWorkoutData(workoutroute)
            }
            
            print("Successfully loaded all route data informations for the workout: \(workout)")
        }
    }
    
    fileprivate func loadWorkouts() {
        WorkoutDataStore.shared().loadWorkouts(interestedActivities: self.interestedActivities, progressTracker: { (state, item) in
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
                self.loadWorkoutRoutes(workout)
            }
        }
    }
}
