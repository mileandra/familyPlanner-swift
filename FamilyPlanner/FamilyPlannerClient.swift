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

    var currentUser : User?

}
