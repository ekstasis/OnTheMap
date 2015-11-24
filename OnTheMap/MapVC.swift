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
        
        mapView.delegate = self
        
        client.getLocations() { locations, error in
            print("getlocations CH")
            if let error = error {
                print(error)
            } else {
                self.client.studentLocations = StudentInformation.arrayFromJSON(locations!)
                self.populateAnnotations()
            }
        }
        print("did getlocations handler start?")
    }
    
    /////
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.mapView.showAnnotations(self.client.annotations, animated: true)
    }
    
    func populateAnnotations() {
        
        for student in client.studentLocations {
            let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                client.annotations.append(newAnnotation)
        }
        
        mapView.addAnnotations(self.client.annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin View") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
            pinView?.canShowCallout = true
//            pinView?.pinColor = MKPinAnnotationColor.Red
        } else {
            pinView?.annotation = annotation
        }
        let detailButton = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = detailButton
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        ///
    }
}

