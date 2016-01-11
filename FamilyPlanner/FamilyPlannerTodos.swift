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
    func createTodo(todo: Todo, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        if Connection.connectedToNetwork() == false {
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil) // just save the todo, we will sync it later
            })
            return
        }
        
        let params = [
            "todo": [
                "title" : todo.title,
                "completed": todo.completed
            ]
        ]
        
        handleRequest(true, url: Methods.TODOS, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            todo.remoteID = NSNumber(integer: data!["id"].intValue)
            todo.synced = true
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
    
    func sync(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        if Connection.connectedToNetwork() == false {
            completionHandler(success: true, errorMessage: nil)
            return
        }
        
        var params:[String:String]? = nil
        if lastSyncTime != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZ"
            params = [
                "since": formatter.stringFromDate(lastSyncTime!)
            ]
        }

        handleRequest(true, url: Methods.TODOS, type: Alamofire.Method.GET, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            let json = data!
            
            if let todos = json["todos"].array {
                for todo in todos {
                    // We need to check if we already have the todo saved
                    let predicate = NSPredicate(format: "remoteID == %@", NSNumber(integer: todo["id"].intValue))
                    
                    let fetchRequest = NSFetchRequest(entityName: "Todo")
                    fetchRequest.predicate = predicate
                    
                    do {
                        let fetchedEntities = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Todo]
                        if fetchedEntities.count == 1 {
                            fetchedEntities.first?.title = todo["title"].stringValue
                            fetchedEntities.first?.completed = todo["completed"].boolValue
                        } else {
                            // we do not have any results - create a new Todo
                            let properties = [
                                "title": todo["title"].stringValue,
                                "completed": todo["completed"].boolValue,
                                "id": todo["id"].intValue
                            ]
                            Todo(properties: properties, group: self.currentUser!.group!, context: self.sharedContext)
                        }
                    } catch {
                        print("There was an error while syncing")
                    }
                    
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                self.saveLastSyncTime(formatter.dateFromString(json["synctime"].stringValue))
            }
            
            self.syncToServer() { success, errorMessage in
                dispatch_async(dispatch_get_main_queue(), {
                    NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.LAST_UPDATE_TIME)
                    CoreDataStackManager.sharedInstance.saveContext()
                    completionHandler(success: success, errorMessage: errorMessage)
                })
            }
            return
        }
    }
    
    func syncToServer(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        if Connection.connectedToNetwork() == false {
            completionHandler(success: true, errorMessage: nil)
            return
        }
       
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        let predicate = NSPredicate(format: "synced == %@", false)
        fetchRequest.predicate = predicate
        
        var todos = [Todo]()
        
        do {
            
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Todo]
            todos = fetchResults!
            
            let group = dispatch_group_create()
            
            for todo in todos {
                dispatch_group_enter(group)
                if todo.remoteID == nil {
                    //create
                    createTodo(todo) { success, errorMessage in
                        if success {
                            dispatch_group_leave(group)
                        }
                    }
                } else {
                    //update
                    updateTodo(todo) { success, errorMessage in
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
    
    func updateTodo(todo: Todo, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        let params = [
            "todo": [
                "title": todo.title,
                "completed": todo.completed
            ]
        ]
        // in case something goes wrong we wanna sync later
        todo.synced = false
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
        })
        
        handleRequest(true, url: Methods.TODOS + "\(todo.remoteID)", type: Alamofire.Method.PUT, params: params) { success, errorMessage, data in
            
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            todo.synced = true
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
}