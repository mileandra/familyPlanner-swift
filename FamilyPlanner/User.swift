//
// Created by Julia Will on 13.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation

struct User {
    var email : String
    var auth_token : String
    var group_id : Int?
    // TODO: persist currentUser as NSManagedObject
}
