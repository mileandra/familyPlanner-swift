//
// Created by Julia Will on 11.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation

extension FamilyPlannerClient {

    struct Constants {
        static func BASE_URL() -> String {
            return Platform.isSimulator ?  "http://family-planner.dev/api/" : "https://evening-badlands-8128.herokuapp.com/api/"
        }
    }

    struct Methods {
        static let SESSIONS = "sessions/"
        static let USERS    = "users/"
        static let GROUPS   = "groups/"
        static let INVITE   = "invites/"
    }
}