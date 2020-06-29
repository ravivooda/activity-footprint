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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            WorkoutDataStore.loadWorkouts { (workouts, error) in
                guard error == nil, let workouts = workouts else {
                    print("Error occurred while reading health data \(error)")
                    return
                }
                
                guard workouts.count != 0 else {
                    print("Empty workouts")
                    return
                }
                
                print("Workouts: \(workouts)")
            }
        }
    }
}
