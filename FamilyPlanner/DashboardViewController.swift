//
//  DashboardViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 15.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FamilyPlannerClient.sharedInstance.isAuthenticated() == false{
            showLoginScreen()
        } else {
            showDashboard()
        }
    }
    
    func showDashboard() {
        navigationController?.navigationBarHidden = false
    }
    
    func showLoginScreen() {
        navigationController?.navigationBarHidden = true
        performSegueWithIdentifier("showLoginSegue", sender: self)
    }
}
