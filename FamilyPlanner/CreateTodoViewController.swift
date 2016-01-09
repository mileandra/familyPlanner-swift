//
//  CreateTodoViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 05.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit

class CreateTodoViewController: UIViewController, AlertRenderer {

    @IBOutlet weak var todoTextField: CustomizableTextField!
    
    @IBAction func saveButtonTouch(sender: AnyObject) {
        let title = todoTextField.text!
        
        let params = [
            "todo": [
                "title": title
            ]
        ]
        if title == "" {
            presentAlert("Error", message: "Please enter a desciption")
            return
        }
        EZLoadingActivity.show("Saving ...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createTodo(params) { success, errorMessage in
            if success {
                EZLoadingActivity.hide(success: true, animated: false)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
}
