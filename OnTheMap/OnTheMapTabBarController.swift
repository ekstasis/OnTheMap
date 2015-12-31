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
    let newLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "newLocation")
    let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
    
    let rightButtons = [refreshButton, newLocationButton]
    
    navigationItem.setRightBarButtonItems(rightButtons, animated: true)
    navigationItem.setLeftBarButtonItem(logoutButton, animated: true)
    
    // For some reason List icon not working right unless set programatically
    let tableItem = UITabBarItem(title: "List", image: UIImage.init(named: "list"), tag: 0)
    let tableView = self.viewControllers![1] as! TableVC
    tableView.tabBarItem = tableItem
  }
  
  func logOut() {
    
    let client = OTMClient.sharedInstance()
    
    client.deleteSession() { errorString in
      if let error = errorString {
        self.showAlert(error)
      }
    }
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func newLocation() {
    let newLocationVC = storyboard?.instantiateViewControllerWithIdentifier("New Location") as! NewLocationVC
    presentViewController(newLocationVC, animated: true, completion: nil)
  }
  
  // Map and List views have their own ways of refreshing, so they conform to Refreshable protocol
  func refresh() {
    let displayedTab = viewControllers![selectedIndex] as! Refreshable
    displayedTab.refresh()
  }
  
  func showAlert(errorString: String) {
    dispatch_async(dispatch_get_main_queue()) {
      let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
      let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
      alert.addAction(action)
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
}
