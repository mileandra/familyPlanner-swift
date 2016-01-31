//
//  ManageGroupViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 27.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class ManageGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, AlertRenderer {
    
    var code: String?
    
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var invitationView: UIView!
    
    @IBOutlet weak var invitationCode: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    
    // TODO: manage group members
    
    override func viewDidLoad() {
        invitationView.hidden = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        fetchObjectsFromStore()
    }
    
    @IBAction func inviteButtonTouch(sender: AnyObject) {
        
        EZLoadingActivity.show("Generating Code...", disableUI: true)
        FamilyPlannerClient.sharedInstance.createInvite() { success, errorMessage, code in
            if success {
                self.tableViewTop.constant = 130
                EZLoadingActivity.hide(success: true, animated: false)
                self.invitationCode.text = code!
                self.code = code!
                self.invitationView.hidden = false
            } else {
                EZLoadingActivity.hide(success: false, animated: false)
                self.invitationView.hidden = true
                self.presentAlert("Error", message: errorMessage!)
            }
        }
    }
    
    @IBAction func shareButtonTouch(sender: AnyObject) {
        let textToShare = "Join our family on Family Planner. Here is your invitation code: \(code!)"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activity, completed, items, error) in
            if (completed) {
                print("sharing done")
            }
        }
        presentViewController(activityViewController, animated: true, completion:nil)

        
    }
    
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        invitationView.hidden = true
        self.tableViewTop.constant = 37
    }
    
    
    //MARK: Core Data
    func fetchObjectsFromStore() {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print(error)
        }
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "group == %@", FamilyPlannerClient.sharedInstance.getGroup()!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?)
    {
        switch(type) {
            
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath],
                    withRowAnimation:UITableViewRowAnimation.Fade)
            }
            
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath],
                    withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        case .Update:
            if let indexPath = indexPath {
                configureCell(tableView.cellForRowAtIndexPath(indexPath)!, indexPath: indexPath)
            }
            break
            
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths([newIndexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type) {
            
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    //MARK: TableView
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let user = self.fetchedResultsController.objectAtIndexPath(indexPath) as! User
        cell.textLabel?.text = user.name
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects != nil {
            let count = fetchedResultsController.fetchedObjects!.count
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell")!
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let user = fetchedResultsController.objectAtIndexPath(indexPath) as! User
        if user.isGroupOwner {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let user = fetchedResultsController.objectAtIndexPath(indexPath) as! User
            if user.isGroupOwner {
                return
            }
            EZLoadingActivity.show("Removing...", disableUI: true)
            FamilyPlannerClient.sharedInstance.removeUserFromGroup(user) { success, errorMessage in
                if success {
                    EZLoadingActivity.hide(success: true, animated: false)
                } else {
                    EZLoadingActivity.hide(success: false, animated: false)
                    self.presentAlert("Error", message: errorMessage!)
                }
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}
