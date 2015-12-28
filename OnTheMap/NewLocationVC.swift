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
        
        locationStack.hidden = false  // set to true to reproduce bug
        webSiteStack.hidden = true
        submitButton.hidden = true
        
        activityIndicator = UIActivityIndicatorView(frame: view.frame)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
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
            
            guard let coordinates = placeMarks?[0].location?.coordinate else {
                self.showAlert("Unable to locate \"\(self.locationText)\".")
                self.locationTextView.text = "Enter Your Location Here"
                self.stopActivityIndicator()
                return
            }
            
            self.locationCoords = coordinates
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.locationCoords
            self.userLocationMap.addAnnotation(annotation)
            
            // zoom in a bit
            self.userLocationMap.setCenterCoordinate(self.locationCoords, animated: true)
            
            // present next views
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
        
        let client = OTMClient.sharedInstance()
        
        self.startActivityIndicator()
        
        client.checkForPreviousSubmission { objectID, errorString in
            guard errorString == nil else {
                self.stopActivityIndicator()
                self.showAlert(errorString!)
                return
            }
            
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
    * UITextViewDelegate
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
    * UITextFieldDelegate
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        url = textField.text!
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert(errorString: String) {
        
        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
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
            for subView in self.view.subviews {
                subView.alpha = 1.0
            }
        }
    }
}
