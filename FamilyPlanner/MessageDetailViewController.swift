//
//  MessageDetailViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 16.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController {
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var sendAnswerButton: UIButton!
    
    
    var message : Message!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: show Messages
        //TODO: set Title to subject
        //TODO: slide view up with Keyboard
    }

    @IBAction func sendAnswerButtonTouch(sender: AnyObject) {
        print("New Answer to message")
    }
}
