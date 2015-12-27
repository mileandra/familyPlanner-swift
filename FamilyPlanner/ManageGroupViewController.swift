//
//  ManageGroupViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 27.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class ManageGroupViewController: UIViewController, AlertRenderer {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var invitationView: UIView!
    
    @IBOutlet weak var invitationCode: UITextField!
    
    //TODO: generate invite code
    // TODO: share invite code
    // TODO: manage group members
    
    override func viewDidLoad() {
        invitationView.hidden = true
        
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }

    }
    
    @IBAction func inviteButtonTouch(sender: AnyObject) {
        invitationView.hidden = false
        EZLoadingActivity.show("Generating Code...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createInvite() { success, errorMessage, code in
            if success {
                EZLoadingActivity.hide(success: true, animated: false)
                self.invitationCode.text = code!
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.invitationView.hidden = true
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
    
    @IBAction func shareButtonTouch(sender: AnyObject) {
    }
    
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        invitationView.hidden = true
    }
    
}
