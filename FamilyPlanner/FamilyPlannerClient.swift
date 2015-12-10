//
//  FamilyPlannerClient.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import Alamofire

class FamilyPlannerClient: NSObject {
    
    static let sharedInstance = FamilyPlannerClient()
    

    func loginUser(email: String, password: String) {
        
    }
    
    func signupUser(email: String, password: String, passwordConfirmation: String) {
        
    }
    
    func showUser(userid: Int) {
        Alamofire.request(.GET, "http://family-planner.dev/api/users/\(userid)")
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }
}
