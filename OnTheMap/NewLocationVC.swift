//
//  NewLocationVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit

class NewLocationVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findMeButton: UIButton!
    
    var locationText: String!
    var locationCoords: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        findMeButton.titleLabel!.numberOfLines = 1
        findMeButton.titleLabel!.adjustsFontSizeToFitWidth = true
        findMeButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping
        
    }
    
    @IBAction func pressedFindLocation(sender: UIButton) {
        locationText = locationTextView.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationText) { placeMarks, error in
            guard error == nil else {
                print(error)
                return
            }
            if let coordinates = placeMarks?[0].location?.coordinate {
                self.locationCoords = coordinates
            }
            print(self.locationCoords)
        }
        // present next views
        stackView.hidden = true
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
}
