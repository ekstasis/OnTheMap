//
//  Annotation.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/22/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
//    var firstName = String()
//    var lastName = String()
//    let latitude: CLLocationDegrees
//    let longitude: CLLocationDegrees
//    let website: String
    
    init(firstName: String, lastName: String, latitude: Double, longitude: Double, url: String) {
        
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        title = "\(firstName) \(lastName)"
        subtitle = url
        
    }
    
}