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

    func signupUser(params: [String : AnyObject]?) {
        Alamofire.request(.POST, Constants.BASE_URL + Methods.USERS, parameters: params).responseJSON { response in
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                self.persistUser(json)
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