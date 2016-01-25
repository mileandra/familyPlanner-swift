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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginScreen", name: "userLogoutNotification", object: nil)
        
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if FamilyPlannerClient.sharedInstance.isAuthenticated() && FamilyPlannerClient.sharedInstance.hasGroup() == false {
            showCreateGroupScreen()
        } else if FamilyPlannerClient.sharedInstance.isAuthenticated() && FamilyPlannerClient.sharedInstance.hasGroup() {
            // Start a Sync in the background Queue
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                FamilyPlannerClient.sharedInstance.sync() { success, errorMessage in
                }
                FamilyPlannerClient.sharedInstance.syncMessages() { success, errorMessage in
                }
            })
           
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
