//
//  FamilyPlannerClient.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreData

class FamilyPlannerClient: NSObject {
    
    static let sharedInstance = FamilyPlannerClient()

    var currentUser : User?
    var lastSyncTime : NSDate = NSDate()
    
    var alamofireManager:Alamofire.Manager?

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
    
    func handleRequest(auth: Bool, url: String, type: Alamofire.Method ,params: [String: AnyObject]?, completionHandler: (success: Bool, errorMessage: String?, data: JSON?) -> Void) {
        
        //check for internet connection
        if Connection.connectedToNetwork() == false {
            completionHandler(success: false, errorMessage: "You have no internet connection", data: nil)
            return
        }
        
        var headers:[String:String]? = nil
        
        if auth {
            if currentUser == nil {
                completionHandler(success: false, errorMessage: "You are not logged in", data: nil)
                return
            }
            headers = [
                "Authorization": currentUser!.auth_token
            ]

        }
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 5 // time out after x seconds
        
        alamofireManager = Alamofire.Manager(configuration: configuration)
        
        alamofireManager!.request(type, Constants.BASE_URL() + url, parameters: params, headers: headers).responseJSON { response in
            if response.result.isFailure {
                completionHandler(success: false, errorMessage:  "A technical error occurred", data: nil)
                return
            }
            
            if let JSONObject = response.result.value {
                let json = JSON(JSONObject)
                print("JSON: \(json)")
                if let errorMessage = json["errors"].string {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, errorMessage: errorMessage, data: nil)
                    })
                    return
                }
                completionHandler(success: true, errorMessage: nil, data: json)
            }
            
        }
    }
 
}
