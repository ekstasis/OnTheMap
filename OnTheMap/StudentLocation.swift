//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/10/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

struct StudentLocation {
    let createdAt: String // "2015-02-24T22:35:30.639Z",
    let firstName: String // "John",
    let lastName: String // "Doe",
    let latitude: Double // 37.322998,
    let longitude: Double // -122.032182,
    let mapString: String // "Cupertino, CA",
    let mediaURL: String // "https://udacity.com",
    let objectID: String // "8ZEuHF5uX8",
    let userID: String // "1234",
    let updatedAt: String // "2015-03-11T02:42:59.217Z"
    
    init(location: [String: AnyObject]) {
        createdAt = location["createdAt"] as! String
        firstName = location["firstName"] as! String
        lastName = location["lastName"] as! String
        latitude = location["latitude"] as! Double
        longitude = location["longitude"] as! Double
        mapString = location["mapString"] as! String
        mediaURL = location["mediaURL"] as! String
        objectID = location["objectId"] as! String
        userID = location["uniqueKey"] as! String
        updatedAt = location["updatedAt"] as! String
    }
    
    static func arrayFromJSON(json: [String: AnyObject]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        let locations = json["results"] as! [[String: AnyObject]]
        for location in locations {
            studentLocations.append(StudentLocation(location: location))
        }
        return studentLocations
    }
}