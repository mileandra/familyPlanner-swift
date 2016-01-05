//
//  TodoViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 05.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit

class TodoViewController: UITableViewController {

    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (revealViewController() != nil) {
            menuBtn.target = revealViewController()
            menuBtn.action = Selector("revealToggle:")
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
    }
}
