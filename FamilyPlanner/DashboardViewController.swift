//
//  DashboardViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 15.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var todoStatusLabel: UILabel!
    @IBOutlet weak var messageStatusLabel: UILabel!
    
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FamilyPlannerClient.sharedInstance.isAuthenticated() == false{
            showLoginScreen()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLoginScreen", name: "userLogoutNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupTimer", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        updateTodoStatus()
        updateMessageStatus()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if FamilyPlannerClient.sharedInstance.isAuthenticated() && FamilyPlannerClient.sharedInstance.hasGroup() == false {
            showCreateGroupScreen()
        }
        setupTimer()
    }

    
    func setupTimer() {
        if FamilyPlannerClient.sharedInstance.isAuthenticated() && FamilyPlannerClient.sharedInstance.hasGroup() {
            if timer == nil {
                timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "syncData", userInfo: nil, repeats: true)
            }
            
            syncData()
        }

        
    }
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            print("stopping timer")
        }
    }
    
    func syncData() {
        print("Sync data")
        // Start a Sync in the background Queue
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            FamilyPlannerClient.sharedInstance.sync() { success, errorMessage in
                self.updateTodoStatus()
            }
            FamilyPlannerClient.sharedInstance.syncMessages() { success, errorMessage in
                self.updateMessageStatus()
            }
        })
    }
    
    func updateTodoStatus() {
        if FamilyPlannerClient.sharedInstance.isAuthenticated() == false || FamilyPlannerClient.sharedInstance.hasGroup() == false {
            return
        }
        var labelText = "You have no uncompleted Todos"
        
        let predicate = NSPredicate(format: "group = %@ AND completed = %@", FamilyPlannerClient.sharedInstance.getGroup()!, false)
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        fetchRequest.predicate = predicate
        
        do {
            let todos = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Todo]
            if todos.count == 1 {
                labelText = "You have one uncompleted Todo"
            } else if todos.count > 1 {
                labelText = "You have \(todos.count) uncompleted Todos"
            }
        } catch {
            print("Unable to get any todos")
        }
        todoStatusLabel.text = labelText
    }
    
    func updateMessageStatus() {
        if FamilyPlannerClient.sharedInstance.isAuthenticated() == false || FamilyPlannerClient.sharedInstance.hasGroup() == false {
            return
        }
        var labelText = "You have no unread messages"
        let predicate = NSPredicate(format: "group = %@ AND read = %@ AND (parent = nil)", FamilyPlannerClient.sharedInstance.getGroup()!, false)
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.predicate = predicate
        
        do {
            let todos = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Message]
            if todos.count == 1 {
                labelText = "You have one unread Message"
            } else if todos.count > 1 {
                labelText = "You have \(todos.count) unread Messages"
            }
        } catch {
            print("Unable to get any messages")
        }
        messageStatusLabel.text = labelText
    }
  
    //TODO: show activity (members joining)
    
    func showLoginScreen() {
        
        navigationController?.navigationBarHidden = true
        performSegueWithIdentifier("showLoginSegue", sender: self)
    }
    
    func showCreateGroupScreen() {
        navigationController?.navigationBarHidden = true
        performSegueWithIdentifier("showCreateGroupSegue", sender: self)
    }
    
    @IBAction func viewTodosButtonTouch(sender: AnyObject) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Todos", bundle: nil)
        let navController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("todoViewController") as! UINavigationController
        revealViewController().setFrontViewController(navController, animated: true)
    }
    
    @IBAction func viewMessagesButtonTouch(sender: AnyObject) {
        let storyboard:UIStoryboard = UIStoryboard(name: "Messages", bundle: nil)
        let navController:UINavigationController = storyboard.instantiateViewControllerWithIdentifier("messagesViewController") as! UINavigationController
        revealViewController().setFrontViewController(navController, animated: true)
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
}
