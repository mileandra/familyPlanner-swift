//
// Created by Julia Will on 11.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation

extension FamilyPlannerClient {

    struct Constants {
        static func BASE_URL() -> String {
            //return Platform.isSimulator ?  "http://family-planner.dev/api/" : ""https://evening-badlands-8128.herokuapp.com/api/ - for local development
            return "https://evening-badlands-8128.herokuapp.com/api/"
            
        }
        static let LAST_TODO_UPDATE_TIME = "LastTodoUpdateTime"
        static let LAST_MESSAGE_UPDATE_TIME = "LastMessageUpdateTime"
    }

    struct Methods {
        static let SESSIONS         = "sessions/"
        static let USERS            = "users/"
        static let GROUPS           = "groups/"
        static let INVITE           = "invites/"
        static let INVITE_ACCEPT    = "invites/accept/"
        static let TODOS            = "todos/"
        static let MESSAGES         = "messages/"
    }
}