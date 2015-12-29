
//
//  Platform.swift
//  FamilyPlanner
//
//  Created by Julia Will on 28.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import Foundation

// From http://themainthread.com/blog/2015/06/simulator-check-in-swift.html
// Check for simulator
struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}