//
// Created by Julia Will on 11.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import Alamofire

extension FamilyPlannerClient {

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
            self.sharedContext.deleteObject(self.currentUser!)
            self.currentUser = nil
            CoreDataStackManager.sharedInstance.saveContext()
            completionHandler(success: true, errorMessage: nil)
        })
    }
    
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
                completionHandler(success: true, errorMessage: nil)
            })
            return
        }
        
    }


    
        
    func persistUser(json: JSON, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        print("JSON: \(json)")
        let properties = [
            "email": json["email"].stringValue,
            "name": json["name"].stringValue,
            "id" : json["id"].intValue,
            "auth_token" : json["auth_token"].stringValue
        ]
        self.currentUser = User(properties: properties, context: sharedContext)
        
        // see if the user already is assigned to a group
        if json["group"]["id"].int != nil {
            let group = Group(id: json["group"]["id"].intValue, name: json["group"]["name"].stringValue, ownerID: json["group"]["owner_id"].intValue, context: sharedContext)
            self.currentUser!.group = group
            print("current user remoteID \(self.currentUser!.remoteID)")
            print("group owner id \(group.ownerID)")
            
            if (Int(group.ownerID) == Int(self.currentUser!.remoteID)) {
                self.currentUser!.isGroupOwner = true
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
            completionHandler(success: true, errorMessage: nil)
        })
    }

}