//
//  SignUpViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, AlertRenderer, TapKeyboardDismisser {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizeTap()
    }
    

    @IBOutlet weak var emailField: CustomizableTextField!
    
    @IBOutlet weak var passwordField: CustomizableTextField!
    
    @IBOutlet weak var passwordConfirmField: CustomizableTextField!
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        
        // Get internet connectivity
        if Connection.connectedToNetwork() == false {
            presentAlert("Error", message: "No Internet Connection")
            return
        }
        
        let email = emailField.text!
        let password = passwordField.text!
        let passwordConfirmation = passwordConfirmField.text!
        
        if (email == "" || password == "" || passwordConfirmation == "") {
            presentAlert("Error", message: "Please fill in all fields")
            return
        }
        if password != passwordConfirmation {
            presentAlert("Error", message: "Your password does not match the confirmation")
            return
        }
        
        let params = [
            "user": [
                "email": email,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
        ]
        
        EZLoadingActivity.show("Signing up...", disableUI: true)
        FamilyPlannerClient.sharedInstance.signupUser(params) { success, errorMessage in
            
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                self.navigationController?.navigationBarHidden = false
                self.navigationController?.popToRootViewControllerAnimated(true)                
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Oops", message: errorMessage!)
            }
            
        }
    }
    
    func recognizeTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
