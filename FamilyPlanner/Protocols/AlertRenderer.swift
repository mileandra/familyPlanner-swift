//
// Created by Julia Will on 19.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import Foundation
@objc

protocol AlertRenderer {
   optional func presentAlert()
}

// Implement the default alert view for all UIViewControllers that extend the protocol
extension AlertRenderer where Self: UIViewController {
    func presentAlert(title: String, message: String, buttonText: String = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}