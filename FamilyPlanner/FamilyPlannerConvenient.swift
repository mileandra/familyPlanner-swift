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
        //Destroy the current session on the server
        let params = [
            "Authorization": currentUser!.auth_token
        ]
        Alamofire.request(.DELETE, Constants.BASE_URL + Methods.SESSIONS, parameters: params).responseJSON { response in
            //actually we do not care what happens here - worst thing that can happen is that the user's auth code will stay
            // active on the server
            dispatch_async(dispatch_get_main_queue(), {
                self.sharedContext.deleteObject(self.currentUser!)
                self.currentUser = nil
                CoreDataStackManager.sharedInstance.saveContext()
                completionHandler(success: true, errorMessage: nil)
            })
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