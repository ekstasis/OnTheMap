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
    
    var testCounter = 0
    
    let client = OTMClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
    }
    
    /////
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateAnnotations()
    }
    
    func populateAnnotations() {
        
        // Clear the map's annotations by removing the current annotation array
        map.removeAnnotations(map.annotations)
        
        client.getLocations() { locations, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            self.client.studentLocations = StudentInformation.arrayFromJSON(locations!)
            
            for student in self.client.studentLocations {
                let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                self.map.addAnnotation(newAnnotation)
                print("\(self.testCounter++):  add Annotation: \(student.updatedAt)")
            }
                    self.map.showAnnotations(self.map.annotations, animated: true)
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

