//
//  SideMenuViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 18.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTouch(sender: UIButton) {
        print("logout")
        FamilyPlannerClient.sharedInstance.logoutUser() { success, errorMessage in
            // close the side menu
            self.revealViewController().revealToggle(self)
            // sending out a notification to notify the dashboardController
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "userLogoutNotification", object: nil))
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
