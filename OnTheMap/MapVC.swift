//jesus"i
//  MapVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
////////
    var testCounter = 0
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
    }
    
///// or viewdidappear?
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateAnnotations()
    }
    
    func populateAnnotations() {
        
        // This function also use for refreshing
        map.removeAnnotations(map.annotations)
        
        client.getLocations() { locations, error in
            
            guard error == nil else {
//// ERROR
                print(error)
                return
            }
//// variable names
            self.client.studentLocations = StudentInformation.arrayFromJSON(locations!)
            
            for student in self.client.studentLocations {
                let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.map.addAnnotation(newAnnotation)
                }
                
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var pinView = map.dequeueReusableAnnotationViewWithIdentifier("Pin View") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
            pinView?.canShowCallout = true
        } else {
            pinView?.annotation = annotation
        }
        let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = detailButton
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callouttapped")
    }
}

