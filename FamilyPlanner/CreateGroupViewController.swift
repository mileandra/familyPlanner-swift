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
        if invitationCodeField.text == "" {
            presentAlert("Error", message: "Please enter an invitation code")
            return
        }
    }
    
    @IBAction func createFamilyButtonTouch(sender: AnyObject) {
        if familyNameField.text == "" {
            presentAlert("Error", message: "Please enter a family name")
            return
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
