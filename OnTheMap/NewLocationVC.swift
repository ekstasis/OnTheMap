//
//  NewLocationVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit

class NewLocationVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
  
  /*
  *  This view controller is used both for location and website entry.
  *  Each mode is handled by a storyboard stack and hidden as appropriate
  */
  @IBOutlet weak var locationStack: UIStackView!
  @IBOutlet weak var locationTextView: UITextView!
  @IBOutlet weak var findMeButton: UIButton!
  
  @IBOutlet weak var webSiteStack: UIStackView!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var enterWebsiteTextField: UITextField!
  @IBOutlet weak var userLocationMap: MKMapView!
  
  @IBOutlet weak var cancelButton: UIButton!
  
  var locationText = String()
  var locationCoords = CLLocationCoordinate2D()
  var url = String()
  
  let client = OTMClient.sharedInstance()
  
  var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationTextView.delegate = self
    enterWebsiteTextField.delegate = self
    
    // Hide the website entry stack
    locationStack.hidden = false
    webSiteStack.hidden = true
    submitButton.hidden = true
    
    activityIndicator = UIActivityIndicatorView(frame: view.frame)
    activityIndicator.activityIndicatorViewStyle = .Gray
  }
  
  @IBAction func pressedFindLocation(sender: UIButton) {
    
    locationText = locationTextView.text
    
    guard locationText != "Enter Your Location Here" else {
      showAlert("Please enter a location.")
      return
    }
    
    startActivityIndicator()
    
    let geocoder = CLGeocoder()
    
    geocoder.geocodeAddressString(locationText) { placeMarks, error in
      
      guard error == nil else {
        self.stopActivityIndicator()
        self.showAlert(error!.localizedDescription)
        return
      }
      
      // If the geocoder finds multiple locations for some reason, use the first one
      guard let coordinates = placeMarks?[0].location?.coordinate else {
        self.stopActivityIndicator()
        self.showAlert("Unable to locate \"\(self.locationText)\".")
        return
      }
      
      self.locationCoords = coordinates
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = self.locationCoords
      self.userLocationMap.addAnnotation(annotation)
      
      // Zoom in
      let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
      self.userLocationMap.region = MKCoordinateRegion(center: self.locationCoords, span: span)
      
      // Switch to website entry mode
      self.locationStack.hidden = true
      self.webSiteStack.hidden = false
      self.submitButton.hidden = false
      self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
      
      self.stopActivityIndicator()
    }
  }
  
  @IBAction func submitButton(sender: UIButton) {
    
    guard !url.isEmpty else {
      showAlert("Please enter a website.")
      return
    }
    
    // URL must have http(s)://
    let range = url.rangeOfString("http", options: NSStringCompareOptions.CaseInsensitiveSearch)
    if range == nil {
      url = "http://" + url
    }
    
    // Checks for valid URL and opens URL
    guard let website = NSURL(string: url) where UIApplication.sharedApplication().canOpenURL(website) else {
      self.showAlert("There appears to be something wrong with your URL")
      return
    }
    
    let client = OTMClient.sharedInstance()
    
    self.startActivityIndicator()
    
    client.checkForPreviousSubmission { objectID, errorString in
      guard errorString == nil else {
        self.stopActivityIndicator()
        self.showAlert(errorString!)
        return
      }
      
      // Previous submission has custom alert, doesn't use showAlert()
      if let objectID = objectID {
        self.stopActivityIndicator()
        let message = "You have submitted a location previously.  Would you like to create a new one?"
        let alert = UIAlertController(title: "Previous Submission", message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in
          self.startActivityIndicator()
          self.submitLocation(objectID)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        dispatch_sync(dispatch_get_main_queue()) {
          self.presentViewController(alert, animated: true, completion: nil)
        }
        
      } else {
        self.submitLocation(nil)
      }
      
    }
  }
  
  func submitLocation(objectID: String?) {
    
    let locationInfo : [String : AnyObject] = [
      "uniqueKey" : client.accountKey!,
      "firstName" : client.firstName!,
      "lastName" : client.lastName!,
      "mapString" : locationText,
      "mediaURL" : url,
      "latitude" : locationCoords.latitude,
      "longitude" : locationCoords.longitude
    ]
    
    client.postLocation(locationInfo, objectID: objectID) { errorString in
      
      guard errorString == nil else {
        self.stopActivityIndicator()
        self.showAlert(errorString!)
        return
      }
      
      self.stopActivityIndicator()
      
      dispatch_async(dispatch_get_main_queue()) {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
    
  }
  
  @IBAction func userCancelled(sender: UIButton) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /*
  * UITextViewDelegate -- for geocoder entry
  */
  func textViewDidBeginEditing(textView: UITextView) {
    locationTextView.text = ""
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      locationTextView.resignFirstResponder()
    }
    return true
  }
  
  /*
  * UITextFieldDelegate -- website entry
  */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    url = textField.text!
    textField.resignFirstResponder()
    return true
  }
  
  
  
  func startActivityIndicator() {
    
    dispatch_async(dispatch_get_main_queue()) {
      
      // Dim screen
      for subView in self.view.subviews {
        subView.alpha = 0.3
      }
      
      self.view.addSubview(self.activityIndicator)
      self.view.bringSubviewToFront(self.activityIndicator)
      
      self.activityIndicator.startAnimating()
    }
  }
  
  func stopActivityIndicator() {
    
    dispatch_async(dispatch_get_main_queue()) {
      self.activityIndicator.stopAnimating()
      self.activityIndicator.removeFromSuperview()
      
      // Un-dim screen
      for subView in self.view.subviews {
        subView.alpha = 1.0
      }
    }
  }
  
  func showAlert(errorString: String) {
    
    stopActivityIndicator()
    let alert = Alert(controller: self, message: errorString)
    alert.present()
  }
}
