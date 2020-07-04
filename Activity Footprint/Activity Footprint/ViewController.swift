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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.authorizeHealthKit()
    }
    
    func loadWorkouts() {
        self.present(WorkoutsLoadingViewController(), animated: true, completion: nil)
    }
    
    fileprivate func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (success, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Error occurred in accessing health kit: \(error!)")
                    return
                }
                
                guard success else {
                    print("Does not have access to health kit")
                    return
                }
                
                self.loadWorkouts()
            }
        }
    }
}
