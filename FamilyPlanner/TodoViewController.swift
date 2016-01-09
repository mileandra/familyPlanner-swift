//
//  TodoViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 05.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit
import CoreData

class TodoViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    let cacheName = "TodosCache"
    
    override func viewDidLoad() {
        //TODO: Cleanup button
        
        super.viewDidLoad()
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print(error)
        }
        
        // Bar Button Items
        let rightArchiveBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Archive"), style: .Plain, target: self, action: "archiveTodos")
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addTodo")
      
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem, rightArchiveBarButtonItem], animated: true)
     
        tableView.addSubview(refreshControl)
    }
    
    
    func addTodo() {
        performSegueWithIdentifier("showCreateTodoSegue", sender: self)
    }

    func archiveTodos() {
        let todos = fetchedResultsController.fetchedObjects as! [Todo]
        for todo in todos {
            if todo.completed {
                todo.archived = true
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
        })
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func refresh() {
        FamilyPlannerClient.sharedInstance.sync() { success, errorMessage in
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects != nil {
            return fetchedResultsController.fetchedObjects!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let todo = fetchedResultsController.objectAtIndexPath(indexPath) as! Todo
        cell.textLabel?.text = todo.title
        if (todo.completed == true) {
            cell.imageView?.image = UIImage(named: "CheckboxChecked")
        } else {
            cell.imageView?.image = UIImage(named: "Check")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = fetchedResultsController.objectAtIndexPath(indexPath) as! Todo
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.selectionStyle = .None
        if todo.completed == true {
            todo.completed = false
            cell.imageView?.image = UIImage(named: "Check")
        } else {
            todo.completed = true
            cell.imageView?.image = UIImage(named: "CheckboxChecked")
        }
        FamilyPlannerClient.sharedInstance.updateTodo(todo) { success, errorMessage in
            
        }
    }
    
    //MARK: Core Data
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        let predicate = NSPredicate(format: "archived == %@", false)
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
            
        case .Update: break
            //TODO: implement
            
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
}
