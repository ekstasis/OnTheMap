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
    var url: String!
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        enterWebsiteTextField.delegate = self
        
        locationStack.hidden = false
        webSiteStack.hidden = true
        submitButton.hidden = true
    }
    
    @IBAction func pressedFindLocation(sender: UIButton) {
        
        locationText = locationTextView.text
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationText) { placeMarks, error in
            
            guard let coordinates = placeMarks?[0].location?.coordinate else {
                self.showAlert("Unable to locate \"\(self.locationText)\".")
                self.locationTextView.text = "Enter Your Location Here"
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
        }
        
        
    }
    
    @IBAction func submitButton(sender: UIButton) {
        let client = OTMClient.sharedInstance()
        
        client.checkForPreviousSubmission { objectID, errorString in
            guard errorString == nil else {
                self.showAlert(errorString!)
                return
            }
            if let _ = objectID {
                let message = "You have submitted a location previously.  Would you like to create a new one?"
                    let alert = UIAlertController(title: "Previous Submission", message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
            }
            
            let locationInfo : [String : AnyObject] = [
                "uniqueKey" : client.accountKey!,
                "firstName" : client.firstName!,
                "lastName" : client.lastName!,
                "mapString" : self.locationText,
                "mediaURL" : self.url,
                "latitude" : self.locationCoords.latitude,
                "longitude" : self.locationCoords.longitude
            ]
            
            client.postLocation(locationInfo, objectID: objectID) { errorString in
                guard errorString == nil else {
                    self.showAlert(errorString!)
                    return
                }
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
        presentViewController(alert, animated: true, completion: nil)
    }
}
