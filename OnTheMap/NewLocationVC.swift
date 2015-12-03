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
    
    var locationText: String!
    var locationCoords: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func pressedFindLocation(sender: UIButton) {
        locationText = locationTextView.text
        // geocode it
        // present error if necessary
        // present next views
        stackView.hidden = true
    }
}
