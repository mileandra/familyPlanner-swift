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
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        FamilyPlannerClient.sharedInstance.showUser(1)
    }
}
