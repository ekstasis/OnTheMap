//
//  OnTheMapTabBarController.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action: "logOut")
        navigationItem.setLeftBarButtonItem(logoutButton, animated: true)
        
        let newLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "newLocation")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        let rightButtons = [refreshButton, newLocationButton]
        navigationItem.setRightBarButtonItems(rightButtons, animated: true)
        
        let tableItem = UITabBarItem(title: "List", image: UIImage.init(named: "list"), tag: 0)
        let tableView = self.viewControllers![1] as! TableVC
        tableView.tabBarItem = tableItem
    }

    func logOut() {
        
        let client = OTMClient.sharedInstance()
        client.deleteSession() { errorString in
            print(errorString)
        }
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newLocation() {
        let newLocationVC = storyboard?.instantiateViewControllerWithIdentifier("New Location") as! NewLocationVC
        presentViewController(newLocationVC, animated: true, completion: nil)
    }
    
    func refresh() {
        let displayedTab = viewControllers![selectedIndex] as! Refreshable
        displayedTab.refresh()
    }
}
