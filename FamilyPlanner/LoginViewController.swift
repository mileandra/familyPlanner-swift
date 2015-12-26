//
//  LoginViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 09.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, AlertRenderer {

  
    @IBOutlet weak var emailField: CustomizableTextField!
    @IBOutlet weak var passwordField: CustomizableTextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text       
    
        
        if email == "" || password == "" {
            presentAlert("Error", message: "Please enter your email and password")
            return
        }
       
        EZLoadingActivity.show("Logging in...", disableUI: true)
        FamilyPlannerClient.sharedInstance.loginUser(email!, password: password!) { success, errorMessage in
          
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                print("logged in")
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.navigationController?.navigationBarHidden = false
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Oops", message: errorMessage!)
            }
            
        }
    }
}
