//
//  MapVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.getLocations() { locations, error in
            if let error = error {
                print(error)
            } else {
                self.client.studentLocations = StudentInformation.arrayFromJSON(locations!)
                self.populateAnnotations()
                self.addAnnotations()
            }
        }
    }
    
    func populateAnnotations() {
        
        for student in client.studentLocations {
            let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                client.annotations.append(newAnnotation)
        }
    }
    func addAnnotations() {
        for annotation in client.annotations {
            mapView.addAnnotation(annotation)
        }
    }
}

