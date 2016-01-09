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
    func createTodo(params: [String : AnyObject]?, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        handleRequest(true, url: Methods.TODOS, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            let properties = [
                "title": data!["title"].stringValue,
                "completed": data!["completed"].boolValue,
                "id": data!["id"].intValue
            ]
            Todo(properties: properties, context: self.sharedContext)
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
    
    func sync(completionHandler: (success: Bool, errorMessage: String?) -> Void) {

        handleRequest(true, url: Methods.TODOS, type: Alamofire.Method.GET, params: nil) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            
            if let todos = data!.array {
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
                            Todo(properties: properties, context: self.sharedContext)
                        }
                    } catch {
                        print("There was an error while syncing")
                    }
                    
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.LAST_UPDATE_TIME)
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
            return
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