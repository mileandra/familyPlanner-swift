//
//  DashboardViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 15.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FamilyPlannerClient.sharedInstance.isAuthenticated() == false{
            showLoginScreen()
        }
        if FamilyPlannerClient.sharedInstance.hasGroup() == false {
            showCreateGroupScreen()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginScreen", name: "userLogoutNotification", object: nil)
        
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }    
    
    func showLoginScreen() {
        
        navigationController?.navigationBarHidden = true
        performSegueWithIdentifier("showLoginSegue", sender: self)
    }
    
    func showCreateGroupScreen() {
        navigationController?.navigationBarHidden = true
        performSegueWithIdentifier("showCreateGroupSegue", sender: self)
    }
}
