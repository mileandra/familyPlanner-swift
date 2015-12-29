//
// Created by Julia Will on 29.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import UIKit

struct MenuItem {

    var identifier : String
    var title : String
    var selector: String?
    var segue : String?
    var image : UIImage?

    init(identifier: String, title: String, selector: String?, segue: String?, image: UIImage?) {
        self.identifier = identifier
        self.title = title
        self.selector = selector
        self.segue = segue
        self.image = image
    }
}