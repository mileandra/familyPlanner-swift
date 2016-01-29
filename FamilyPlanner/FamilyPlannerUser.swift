//
// Created by Julia Will on 11.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import Alamofire

extension FamilyPlannerClient {

    // create a new session
    func loginUser(email: String, password: String, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let params = [
                "session": [
                        "email": email,
                        "password": password
                ]
        ]
        
        handleRequest(false, url: Methods.SESSIONS, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            let json = data!
            if let errorMsg = json["errors"].string {
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(success: false, errorMessage: errorMsg)
                })
                return
            } else {
                self.persistUser(json, completionHandler: completionHandler)
            }
        }
    }

    // create a new user
    func signupUser(params: [String : AnyObject]?, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        Alamofire.request(.POST, Constants.BASE_URL() + Methods.USERS, parameters: params).responseJSON { response in
            
            if response.result.isFailure {
                completionHandler(success: false, errorMessage: "A technical error occurred while signing you up")
                return
            }
            
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                if let errorMsg = json["errors"].string {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, errorMessage: errorMsg)
                    })
                    return
                } else {
                    self.persistUser(json, completionHandler: completionHandler)
                }
                
            }
        }
    }
    
    func logoutUser(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        if currentUser == nil {
            //nothing to do, fail silently
            completionHandler(success: true, errorMessage: nil);
            return
        }
        // we should also delete it on the server, but in that case we
        // would not be able to actively use this tool on multiple devices, so we just remove the currentUser for now
        // This has nothing to do with the API, but logically it should stay here
        dispatch_async(dispatch_get_main_queue(), {
            self.currentUser!.isCurrentUser = false
            CoreDataStackManager.sharedInstance.saveContext()
            self.currentUser = nil
            completionHandler(success: true, errorMessage: nil)
        })
    }
    
    // create a new group
    func createGroup(params: [String : AnyObject]?, completionHandler: (success: Bool, errorMessage: String?) -> Void) {

        handleRequest(true, url: Methods.GROUPS, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            let json = data!
            
            let group = Group(id: json["id"].intValue, name: json["name"].stringValue, ownerID: json["owner_id"].intValue, context: self.sharedContext)
            self.currentUser!.group = group
            
            if (group.ownerID == self.currentUser!.remoteID) {
                self.currentUser!.isGroupOwner = true
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
            return
        }
    }
    
    // Create a new invite
    func createInvite(completionHandler: (success: Bool, errorMessage: String?, code: String?) -> Void) {

        handleRequest(true, url: Methods.INVITE, type: Alamofire.Method.POST, params: nil) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage, code: nil)
                return
            }
            let json = data!
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil, code: json["code"].stringValue)
            })
            return

        }
    }

    // Accept an invitation to join a group
    func acceptInvite(params: [String : AnyObject]?, completionHandler: (success: Bool, errorMessage: String?) -> Void) {

        handleRequest(true, url: Methods.INVITE_ACCEPT, type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            let json = data!
            
            let group = Group(id: json["id"].intValue, name: json["name"].stringValue, ownerID: json["owner_id"].intValue, context: self.sharedContext)
            self.currentUser!.group = group
            
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                self.syncGroup(completionHandler);
            })
            return
        }
        
    }
    
    // Only for group owners - they may remove a member from the group
    func removeUserFromGroup(user: User, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let params = [
            "user_id": user.remoteID
        ]
        handleRequest(true, url: "\(Methods.GROUPS)remove_member", type: Alamofire.Method.POST, params: params) { success, errorMessage, data in
            if success == false || data == nil {
                completionHandler(success: false, errorMessage: errorMessage)
                return
            }
            self.sharedContext.deleteObject(user)
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
        }
    }
    
    // Get Group data and members
    func syncGroup(completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        if hasGroup() {
            handleRequest(true, url: Methods.GROUPS + "\(getGroup()!.remoteID)", type: Alamofire.Method.GET, params: nil) { success, errorMessage, data in
                if success == false || data == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, errorMessage: errorMessage)
                    })
                    return
                }
                
                let json = data!
                var ids:[NSNumber] = [NSNumber]()
                if let users = json["users"].array {
                    for user in users {
                        ids.append(NSNumber(integer: user["id"].intValue))
                        // We need to check if we already have the todo saved
                        let predicate = NSPredicate(format: "remoteID == %@", NSNumber(integer: user["id"].intValue))
                        
                        let fetchRequest = NSFetchRequest(entityName: "User")
                        fetchRequest.predicate = predicate
                        
                        do {
                            let fetchedEntities = try self.sharedContext.executeFetchRequest(fetchRequest) as! [User]
                            if fetchedEntities.count == 1 {
                                // just update the name - we can be sure that id won't change
                                fetchedEntities.first?.name = user["name"].stringValue
                                if fetchedEntities.first?.remoteID != self.currentUser!.remoteID {
                                    fetchedEntities.first?.auth_token = nil
                                }
                            } else {
                                // we do not have any results - create a new Todo
                                let properties = [
                                    "name": user["name"].stringValue,
                                    "email": user["email"].stringValue,
                                    "id": user["id"].intValue
                                ]
                                let newUser = User(properties: properties,  context: self.sharedContext)
                                newUser.group = self.getGroup()
                            }
                        } catch {
                            print("There was an error while syncing")
                        }
                    }
                    
                    // We need to remove all users that might still be saved on the device for the group and are not on the server anymore
                    let isPredicate = NSPredicate(format: "NOT(remoteID IN %@) AND group == %@", ids, self.getGroup()!)
                    let fetchRequest = NSFetchRequest(entityName: "User")
                    fetchRequest.predicate = isPredicate
                    do {
                        let fetchedEntities = try self.sharedContext.executeFetchRequest(fetchRequest) as! [User]
                        if fetchedEntities.count > 0 {
                            for user in fetchedEntities {
                                self.sharedContext.deleteObject(user)
                            }
                        }
                    } catch {
                        print("Unable to remove inactive users")
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        CoreDataStackManager.sharedInstance.saveContext()
                        completionHandler(success: true, errorMessage: nil)
                    })
                }
            }
        }
    }
    
    /**
    * Persist the user after sign in
    */
    func persistUser(json: JSON, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let fetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "remoteID == %@", NSNumber(integer: json["id"].intValue))
        fetchRequest.predicate = predicate
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
            currentUser!.email = json["email"].stringValue
            currentUser!.name = json["name"].stringValue
            currentUser!.auth_token = json["auth_token"].stringValue
        } else {
            let properties = [
                "email": json["email"].stringValue,
                "name": json["name"].stringValue,
                "id" : json["id"].intValue,
                "auth_token" : json["auth_token"].stringValue
            ]
            self.currentUser = User(properties: properties, context: sharedContext)

        }

        self.currentUser!.isCurrentUser = true
        
        // make sure the user is removed from group if he is no longer a member
        if self.currentUser!.group != nil && json["group"]["id"].int != nil && self.currentUser!.group!.remoteID != NSNumber(integer:json["group"]["id"].intValue) {
            self.currentUser!.group = nil
        }
        
        if self.currentUser!.group == nil && json["group"]["id"].int != nil {
            let fetchRequest = NSFetchRequest(entityName: "Group")
            let predicate = NSPredicate(format: "remoteID == %@", NSNumber(integer:json["group"]["id"].intValue))
            fetchRequest.predicate = predicate
            var groups:[Group] = []
            do {
                let results = try sharedContext.executeFetchRequest(fetchRequest)
                groups = results as! [Group]
            } catch let error as NSError {
                // only current user failed, so failing silent
                print("An error occured accessing managed object context \(error.localizedDescription)")
            }
            if groups.count > 0 {
                currentUser!.group = groups[0]
            } else {
                let group = Group(id: json["group"]["id"].intValue, name: json["group"]["name"].stringValue, ownerID: json["group"]["owner_id"].intValue, context: sharedContext)
                self.currentUser!.group = group
                print("current user remoteID \(self.currentUser!.remoteID)")
                print("group owner id \(group.ownerID)")
                
                if (Int(group.ownerID) == Int(self.currentUser!.remoteID)) {
                    self.currentUser!.isGroupOwner = true
                }
                
            }
        }
        
        // sync group if the user already belongs to one
        if self.currentUser!.group != nil {
            dispatch_async(dispatch_get_main_queue(), {
                CoreDataStackManager.sharedInstance.saveContext()
                self.syncGroup(completionHandler)
            })
            return
        }
       
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
            completionHandler(success: true, errorMessage: nil)
        })
    }

}