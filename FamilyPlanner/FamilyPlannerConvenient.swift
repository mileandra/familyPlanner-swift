//
// Created by Julia Will on 11.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

extension FamilyPlannerClient {

    func loginUser(email: String, password: String, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        let params = [
                "session": [
                        "email": email,
                        "password": password
                ]
        ]

        Alamofire.request(.POST, Constants.BASE_URL + Methods.SESSIONS, parameters: params).responseJSON { response in

            if response.result.isFailure {
                completionHandler(success: false, errorMessage: "A technical error occurred while logging you in")
                return
            }


            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                if let errorMsg = json["errors"].string {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, errorMessage: errorMsg)
                    })
                    return
                }
                self.persistUser(json)
            }
            completionHandler(success: true, errorMessage: nil)
        }
    }

    func signupUser(params: [String : AnyObject]?, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        Alamofire.request(.POST, Constants.BASE_URL + Methods.USERS, parameters: params).responseJSON { response in
            
            if response.result.isFailure {
                completionHandler(success: false, errorMessage: "A technical error occurred while signing you up")
                return
            }
            
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                self.persistUser(json)
            }
            completionHandler(success: true, errorMessage: nil)
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
        let headers = [
            "Authorization": currentUser!.auth_token
        ]
        Alamofire.request(.POST, Constants.BASE_URL + Methods.GROUPS, parameters: params, headers: headers).responseJSON { response in
            if response.result.isFailure {
                completionHandler(success: false, errorMessage:  "A technical error occurred while creating a group")
                return
            }
            
            if let JSONObject = response.result.value {
                let json = JSON(JSONObject)
                print("JSON: \(json)")
                if let errorMessage = json["errors"].string {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success: false, errorMessage: errorMessage)
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.currentUser!.group_id = json["id"].intValue
                    CoreDataStackManager.sharedInstance.saveContext()
                    completionHandler(success: true, errorMessage: nil)
                })
                return
            }           
            
        }
    }
    
    
    func persistUser(json: JSON) {
        print("JSON: \(json)")
        self.currentUser = User(email: json["email"].stringValue, auth_token: json["auth_token"].stringValue, context: sharedContext)
        dispatch_async(dispatch_get_main_queue(), {
            CoreDataStackManager.sharedInstance.saveContext()
        })
    }

}