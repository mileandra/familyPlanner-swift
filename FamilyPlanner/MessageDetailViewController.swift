//
//  MessageDetailViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 16.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class MessageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AlertRenderer {
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var sendAnswerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var anserBottomConstraint: NSLayoutConstraint!
    
    var message : Message!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
        
        //set height stretching cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70.0
        
        //hide extra empty cells
        //http://stackoverflow.com/questions/28708574/how-to-remove-extra-empty-cells-in-tableviewcontroller-ios-swift
        tableView.tableFooterView = UIView()
        
        //scroll to tableViewbottom
        // http://stackoverflow.com/questions/29378009/how-do-i-automatically-scroll-in-a-table-view-using-swift
        let numberOfSections = self.tableView.numberOfSections
        let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
        
        let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: numberOfSections-1)
        self.tableView.scrollToRowAtIndexPath(indexPath,
            atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        
        //User has seen new message and responses: mark as read
        message.read = true
        FamilyPlannerClient.sharedInstance.updateMessage(message) { success, errorMessage in
            //background-operation: fail silent as we can sync later
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Keyboard show/hide
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //only move view up when editing the bottom textfield
        anserBottomConstraint.constant = getKeyboardHeight(notification)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        anserBottomConstraint.constant = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    //MARK: Send answer
    @IBAction func sendAnswerButtonTouch(sender: AnyObject) {
        let answerText = answerTextField.text
        if answerText == nil {
            presentAlert("Error", message: "Please enter a message")
            return
        }
        
        let properties:NSDictionary = [
            "message" : answerText!,
            "author": FamilyPlannerClient.sharedInstance.currentUser!.name
        ]
        
        let answer = Message(properties: properties, group: FamilyPlannerClient.sharedInstance.getGroup()!, context: sharedContext)
        answer.parent = message
        
        EZLoadingActivity.show("Sending...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createMessage(answer) { success, errorMessage in
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                self.answerTextField.text = ""
                self.answerTextField.endEditing(true)
                self.tableView.reloadData()
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
    
    //MARK: Coredata
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    //MARK: TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell") as! MessageCollectionViewCell!
        
        cell.messageText.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.messageText.numberOfLines = 0
        
        if indexPath.row == 0 {
            cell.metaInfoText.text = message.metaInfoText()
            cell.messageText.text = message.message
        } else {
            let index = indexPath.row - 1
            let childMessage = message.messages![index]
            cell.metaInfoText.text = childMessage.metaInfoText()
            cell.messageText.text = childMessage.message
        }
        
        cell.messageText.sizeToFit()
        cell.metaInfoText.sizeToFit()
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        if message.messages != nil {
            count += message.messages!.count
        }
        return count
    }

    
}
