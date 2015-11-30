//jesus"i
//  MapVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController, MKMapViewDelegate, Refreshable {
    
    @IBOutlet weak var map: MKMapView!
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        refresh()
    }
    
    func refresh() {
        
        map.removeAnnotations(map.annotations)
        
        client.update() { error in
            guard error == nil else {
                print(error)
                return
            }
        }
        
        for student in client.studentLocations {
            let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.map.addAnnotation(newAnnotation)
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

