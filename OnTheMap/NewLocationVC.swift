//
//  NewLocationVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit

class NewLocationVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var locationStack: UIStackView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findMeButton: UIButton!
    
    @IBOutlet weak var webSiteStack: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var enterWebsiteTextField: UITextField!
    @IBOutlet weak var userLocationMap: MKMapView!
    
    var locationText = String()
    var locationCoords = CLLocationCoordinate2D()
    var url = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        enterWebsiteTextField.delegate = self
        userLocationMap.delegate = self
        
        locationStack.hidden = false
        webSiteStack.hidden = true
        submitButton.hidden = true
    }
    
    @IBAction func pressedFindLocation(sender: UIButton) {
        
        locationText = locationTextView.text
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationText) { placeMarks, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let coordinates = placeMarks?[0].location?.coordinate else {
                print("There was a problem with the coordinates!")
                return
            }
            
            self.locationCoords = coordinates
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.locationCoords
            self.userLocationMap.addAnnotation(annotation)
            self.userLocationMap.setCenterCoordinate(self.locationCoords, animated: true)
        }
        
        // present next views
        locationStack.hidden = true
        webSiteStack.hidden = false
        submitButton.hidden = false
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
        //////////// validate text
        url = textField.text!
        return true
    }
}
