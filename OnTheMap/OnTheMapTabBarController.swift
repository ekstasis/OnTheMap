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
    }

    func logOut() {
//        tabBarController?.dismissViewControllerAnimated(true, completion: nil)
        print("Log Out")
    }
    
    func newLocation() {
        let newLocationVC = storyboard?.instantiateViewControllerWithIdentifier("New Location") as! NewLocationVC
        presentViewController(newLocationVC, animated: true, completion: nil)
        
    }
    
    func refresh() {
        print("refresh")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
