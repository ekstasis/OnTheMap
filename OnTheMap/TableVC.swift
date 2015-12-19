//
//  TableVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/29/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class TableVC: UITableViewController, Refreshable {

    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    func refresh() {
        client.update() { locations, errorString in
            guard errorString == nil else {
                self.showAlert(errorString!)
                return
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.studentLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = client.studentLocations[indexPath.row].fullName
        cell.detailTextLabel!.text = client.studentLocations[indexPath.row].mediaURL
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var url = client.studentLocations[indexPath.row].mediaURL
        
//        // URL must have http(s)://
//        let http = "http"
//        let range = url.rangeOfString(http, options: NSStringCompareOptions.CaseInsensitiveSearch)
//        if range == nil {
//            url = http + "://" + url
//        }
        
        guard client.launchSafariWithURLString(url) else {
            showAlert("Error opening URL:  \"\(url)\"")
            return
        }
    }
    
    func showAlert(errorString: String) {
        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
