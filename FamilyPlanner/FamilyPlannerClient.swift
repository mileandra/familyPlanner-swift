//
//  FamilyPlannerClient.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import Alamofire
import CoreData

class FamilyPlannerClient: NSObject {
    
    static let sharedInstance = FamilyPlannerClient()

    var currentUser : User?
    var lastSyncTime : NSDate = NSDate()

    private override init() {
        super.init()
        getLastSyncTime()
        loadCurrentUser()
    }
    
    func getLastSyncTime() {
        if let lastUpdate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey(Constants.LAST_UPDATE_TIME) as? NSDate {
            lastSyncTime = lastUpdate
        }
    }
    
    func loadCurrentUser() {
        let fetchRequest = NSFetchRequest(entityName: "User")
        var users:[User] = []
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest)
            users = results as! [User]
        } catch let error as NSError {
            // only current user failed, so failing silent
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        if users.count > 0 {
            currentUser = users[0]
        }
    }
    
    func isAuthenticated() -> Bool {
        return currentUser != nil
    }
    
    func hasGroup() -> Bool {
        return isAuthenticated() && currentUser?.group != nil
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
}
