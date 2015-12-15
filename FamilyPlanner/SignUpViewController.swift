//
//  SignUpViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: CustomizableTextField!
    
    @IBOutlet weak var passwordField: CustomizableTextField!
    
    @IBOutlet weak var passwordConfirmField: CustomizableTextField!
    
    @IBAction func signUpButtonTouch(sender: AnyObject) {
        let email = emailField.text!
        let password = passwordField.text!
        let passwordConfirmation = passwordConfirmField.text!
        
        //TODO: add validation
        // TODO: add completion Handler
        let params = [
            "user": [
                "email": email,
                "password": password,
                "password_confirmation": passwordConfirmation
            ]
        ]
        FamilyPlannerClient.sharedInstance.signupUser(params)
    }
}
