//
//  CreateGroupViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 26.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, AlertRenderer {

    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var createView: UIView!
    
    @IBOutlet weak var familyNameField: CustomizableTextField!
    @IBOutlet weak var invitationCodeField: CustomizableTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createView.hidden = true
        inviteView.hidden = true
    }

    @IBAction func createButtonTouch(sender: AnyObject) {
        createView.hidden = false
        inviteView.hidden = true
    }
  
    @IBAction func inviteButtonTouch(sender: AnyObject) {
        createView.hidden = true
        inviteView.hidden = false
    }
    
    @IBAction func joinButtonTouch(sender: AnyObject) {
        let invitationCode = invitationCodeField.text!
        
        if invitationCode == "" {
            presentAlert("Error", message: "Please enter an invitation code")
            return
        }
    }
    
    @IBAction func createFamilyButtonTouch(sender: AnyObject) {
        let familyName = familyNameField.text!
        
        if familyName == "" {
            presentAlert("Error", message: "Please enter a family name")
            return
        }
        let params = [
            "group": [
                "name": familyName
            ]
        ]
        
        EZLoadingActivity.show("Creating group...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createGroup(params) { success, errorMessage in
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.navigationController?.navigationBarHidden = false
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Error", message: errorMessage!)
            }
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
