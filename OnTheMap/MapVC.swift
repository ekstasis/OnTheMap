//
//  MapVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do I need to say mapview.delegate = self???
        
        client.getLocations() { locations, error in
            if let error = error {
                print(error)
            } else {
                self.client.studentLocations = StudentInformation.arrayFromJSON(locations!)
                self.populateAnnotations()
            }
        }
    }
    
    /////
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func populateAnnotations() {
        
        for student in client.studentLocations {
            let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                client.annotations.append(newAnnotation)
        }
        
        mapView.addAnnotations(self.client.annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin View")
        
        if pinView == nil {
            pinView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "Pin View")
        } else {
            pinView?.annotation = annotation
        }
            let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
            pinView?.detailCalloutAccessoryView = detailButton
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        ///
    }
}

