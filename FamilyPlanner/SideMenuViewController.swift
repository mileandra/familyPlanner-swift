//
//  SideMenuViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 18.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    
    var menuItems:[MenuItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMenu()
    }

    /**
    * Create the Sidemenu structure
    */
    func setupMenu() {
        menuItems.append(MenuItem(identifier: "dashboard", title: "Dashboard", selector: nil, segue: "showDashboardSegue", image: nil))
        if (FamilyPlannerClient.sharedInstance.currentUser!.isGroupOwner) {
            menuItems.append(MenuItem(identifier: "manageGroup", title: "Manage Group", selector: nil, segue: "showManageGroupSegue", image: nil))
        }
        menuItems.append(MenuItem(identifier: "logoout", title: "Logout", selector: "logout", segue: nil, image: nil))
    }
    
    func logout() {
        FamilyPlannerClient.sharedInstance.logoutUser() { success, errorMessage in        
            // now we no longer have a current user, so the dashboard should handle it when we arrive
            self.performSegueWithIdentifier("showDashboardSegue", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let item = menuItems[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = menuItems[indexPath.row]
        if item.selector != nil {
            // We need a small hack here and create a timer to invoke once
            NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector(item.selector!), userInfo: nil, repeats: false)
        } else if item.segue != nil {
            performSegueWithIdentifier(item.segue!, sender: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
