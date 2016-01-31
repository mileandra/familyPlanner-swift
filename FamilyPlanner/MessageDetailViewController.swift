//
//  MessageDetailViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 16.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class MessageDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AlertRenderer {
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var sendAnswerButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var anserBottomConstraint: NSLayoutConstraint!
    
    var message : Message!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: show Messages
        //TODO: set Title to subject
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

    @IBAction func sendAnswerButtonTouch(sender: AnyObject) {
        let answerText = answerTextField.text
        if answerText == nil {
            presentAlert("Error", message: "Please enter a message")
            return
        }
        
        let properties:NSDictionary = [
            "message" : answerText!
        ]
        
        let answer = Message(properties: properties, group: FamilyPlannerClient.sharedInstance.getGroup()!, context: sharedContext)
        answer.parent = message
        
        EZLoadingActivity.show("Sending...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createMessage(answer) { success, errorMessage in
            if success == true {
                EZLoadingActivity.hide(success: true, animated: false)
                self.answerTextField.text = ""
                self.answerTextField.endEditing(true)
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    //MARK: CollectionView
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("messageCell", forIndexPath: indexPath) as! MessageCollectionViewCell
        if indexPath.row == 0 {
            cell.messageText.text = message.message
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    
}
