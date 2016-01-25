//
//  CreateTodoViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 05.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class CreateTodoViewController: UIViewController, AlertRenderer {

    @IBOutlet weak var todoTextField: CustomizableTextField!
    
    @IBAction func saveButtonTouch(sender: AnyObject) {
        let title = todoTextField.text!
        
        let properties = [
            "title" : title,
            "completed" : false,
            "synced" : false
        ]
        let group = FamilyPlannerClient.sharedInstance.currentUser!.group!
        let todo = Todo(properties: properties, group: group, context: sharedContext)
        
        if title == "" {
            presentAlert("Error", message: "Please enter a desciption")
            return
        }
        EZLoadingActivity.show("Saving ...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createTodo(todo) { success, errorMessage in
            if success {
                EZLoadingActivity.hide(success: true, animated: false)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
}
