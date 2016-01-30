//
//  FamilyPlannerMessages.swift
//  FamilyPlanner
//
//  Created by Julia Will on 11.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

//
//  FamilyPlannerTodos.swift
//  FamilyPlanner
//
//  Created by Julia Will on 09.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import Alamofire

extension FamilyPlannerClient {
    func createMessage(message: Message, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        if Connection.connectedToNetwork() == false {
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil) // just save the todo, we will sync it later
            })
            return
        }
        
        let parentID = message.parent == nil ? nil : message.parent!.remoteID
        
        var params = [
            "message": [
                "message" : message.message
            ]
        ]
        if message.subject != nil {
            params["message"]!["subject"] = message.subject!
        }
        if parentID != nil {
            params["message"]!["responds_id"] = "\(parentID!)"
        }
    
        
        handleRequest(true, url: Methods.MESSAGES, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            message.remoteID = NSNumber(integer: data!["id"].intValue)
            message.synced = Bool(true)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
    
    func syncMessages(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        if hasGroup() == false {
            completionHandler(success: false, errorMessage: "No group")
            return
        }
        if Connection.connectedToNetwork() == false {
            completionHandler(success: true, errorMessage: nil)
            return
        }
        
        var params:[String:String]? = nil
        if getGroup()!.lastMessageSyncTime != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
            params = [
                "since": formatter.stringFromDate(getGroup()!.lastMessageSyncTime!)
            ]
        }
        
        handleRequest(true, url: Methods.MESSAGES, type: Alamofire.Method.GET, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            let json = data!
            
            if let messages = json["messages"].array {
                for message in messages {
                    // We need to check if we already have the todo saved
                    let predicate = NSPredicate(format: "remoteID == %@", NSNumber(integer: message["id"].intValue))
                    
                    let fetchRequest = NSFetchRequest(entityName: "Message")
                    fetchRequest.predicate = predicate
                    
                    do {
                        let fetchedEntities = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Message]
                        if fetchedEntities.count == 1 {
                            fetchedEntities.first?.message = message["message"].stringValue
                        } else {
                            // we do not have any results - create a new Message
                            let properties = [
                                "subject": message["subject"].stringValue,
                                "message": message["message"].stringValue,
                                "id": message["id"].intValue
                            ]
                            let newMessage = Message(properties: properties, group: self.currentUser!.group!, context: self.sharedContext)
                            newMessage.synced = Bool(true)
                            
                        }
                    } catch {
                        print("There was an error while syncing")
                    }
                    
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                self.getGroup()!.lastMessageSyncTime = formatter.dateFromString(json["synctime"].stringValue)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                self.syncMessagesToServer() { success, errorMessage in
                    dispatch_async(dispatch_get_main_queue(), {
                        // No need to save again, as it is saved after all requests
                        completionHandler(success: success, errorMessage: errorMessage)
                    })
                }
            })
            
            return
        }
    }
    
    func syncMessagesToServer(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        if hasGroup() == false {
            completionHandler(success: false, errorMessage: "No Group")
            return
        }
        
        if Connection.connectedToNetwork() == false {
            completionHandler(success: true, errorMessage: nil)
            return
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        let predicate = NSPredicate(format: "(synced == %@) AND (group = %@)", false, self.getGroup()!)
        fetchRequest.predicate = predicate
        
        var messages = [Message]()
        
        do {
            
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Message]
            messages = fetchResults!
            
            let group = dispatch_group_create()
            
            for message in messages {
                dispatch_group_enter(group)
                if message.remoteID == nil {
                    //create
                    createMessage(message) { success, errorMessage in
                        if success {
                            dispatch_group_leave(group)
                        }
                    }
                } else {
                    //update
                    updateMessage(message) { success, errorMessage in
                        if success {
                            dispatch_group_leave(group)
                        }
                    }
                }
            }
            
            
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                completionHandler(success: true, errorMessage: nil)
            }
        } catch let error as NSError {
            print("Sync was not successful \(error)")
        }
    }
    
    func updateMessage(message: Message, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        let params = [
            "message": [
                "message": message.message
            ]
        ]
        // in case something goes wrong we wanna sync later
        message.synced = false
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
        })
        
        handleRequest(true, url: Methods.MESSAGES + "\(message.remoteID)", type: Alamofire.Method.PUT, params: params) { success, errorMessage, data in
            
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            message.synced = true
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
}
