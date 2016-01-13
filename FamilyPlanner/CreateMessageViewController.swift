//
//  CreateMessageViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 13.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class CreateMessageViewController: UIViewController, AlertRenderer {

    @IBOutlet weak var messageTextField: UITextView!
    
    @IBAction func sendMessageButtonTouch(sender: AnyObject) {
        
        let messageText = messageTextField.text!
        
        let properties = [
            "message" : messageText,
            "synced" : false
        ]
        if messageText == "" {
            presentAlert("Error", message: "Please enter a message")
            return
        }
        
        let group = FamilyPlannerClient.sharedInstance.getGroup()
        let message = Message(properties: properties, group: group, context: sharedContext)
        print(message)
        
        EZLoadingActivity.show("Sending...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createMessage(message) { success, errorMessage in
            if success {
                EZLoadingActivity.hide(success: true, animated: false)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
}
