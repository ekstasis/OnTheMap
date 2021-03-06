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
    return StudentInformation.studentLocations.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    cell.textLabel!.text = StudentInformation.studentLocations[indexPath.row].fullName
    cell.detailTextLabel!.text = StudentInformation.studentLocations[indexPath.row].mediaURL
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    var url = StudentInformation.studentLocations[indexPath.row].mediaURL
    
    // URL must have http(s)://
    let range = url.rangeOfString("http", options: NSStringCompareOptions.CaseInsensitiveSearch)
    if range == nil {
      url = "http://" + url
    }
    
    // Check if URL is valid and go ahead an open it
    guard let website = NSURL(string: url) where UIApplication.sharedApplication().openURL(website) else {
      showAlert("Error opening URL:  \"\(url)\"")
      return
    }
  }
  
  func showAlert(errorString: String) {
    let alert = Alert(controller: self, message: errorString)
    alert.present()
  }
}
