//
//  LoginViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 09.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  
    @IBOutlet weak var emailField: CustomizableTextField!
    @IBOutlet weak var passwordField: CustomizableTextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
       
        loginButton.enabled = false
        
        // TODO: add validation
       
        EZLoadingActivity.show("Logging in...", disableUI: true)
        FamilyPlannerClient.sharedInstance.loginUser(email!, password: password!) { success, errorMessage in
            self.loginButton.enabled = true
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                print("logged in")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                print("not logged in")
                //TODO: display error
            }
            
        }
    }
}
