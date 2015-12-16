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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        
        map.removeAnnotations(map.annotations)
        
        client.update() { studentLocations, error in
            guard error == nil else {
                self.showAlert(error!)
                return
            }
            for student in studentLocations! {
                let newAnnotation = Annotation(firstName: student.firstName, lastName: student.lastName, latitude: student.latitude, longitude: student.longitude, url: student.mediaURL)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.map.addAnnotation(newAnnotation)
                }
            }     }
        
        
        
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
        
        guard let annotation = view.annotation as? Annotation else {
            print("Could not cast as Annotation")
            return
        }
        guard var subTitle = annotation.subtitle else {
            print("Could not pull subTitle from annotation")
            return
        }
        
        // URL must have http(s)://
        let http = "http"
        let range = subTitle.rangeOfString(http, options: NSStringCompareOptions.CaseInsensitiveSearch)
        if range == nil {
            subTitle = http + "://" + subTitle
        }
        
        guard client.launchSafariWithURLString(subTitle) else {
            //            //////////////  DEAL WITH ERROR
            print("Error opening URL:  \"\(subTitle)\"")
            return
        }
    }
    
    func showAlert(errorString: String) {
        
        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

