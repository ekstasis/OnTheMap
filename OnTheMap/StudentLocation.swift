//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/10/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

struct StudentInformation {
  
  let createdAt: String // "2015-02-24T22:35:30.639Z",
  let firstName: String // "John",
  let lastName: String // "Doe",
  let latitude: Double // 37.322998,
  let longitude: Double // -122.032182,
  let mediaURL: String // "https://udacity.com",
  let objectID: String // "8ZEuHF5uX8",
  let userID: String // "1234",
  let updatedAt: String // "2015-03-11T02:42:59.217Z"
  
  var fullName: String {
    return "\(firstName) \(lastName)"
  }
  
  init(location: [String: AnyObject]) {
    createdAt = location["createdAt"] as! String
    firstName = location["firstName"] as! String
    lastName = location["lastName"] as! String
    latitude = location["latitude"] as! Double
    longitude = location["longitude"] as! Double
    mediaURL = location["mediaURL"] as! String
    objectID = location["objectId"] as! String
    userID = location["uniqueKey"] as! String
    updatedAt = location["updatedAt"] as! String
  }
  
  // Generates array of StudentInformation structs from dictionary
  static func arrayFromJSON(json: [String: AnyObject], completion: (locationsResult: [StudentInformation]?, errorString: String?) -> Void) {
    
    var studentLocations = [StudentInformation]()
    
    if let locations = json["results"] as? [[String: AnyObject]] {
      for location in locations {
        studentLocations.append(StudentInformation(location: location))
      }
      
      completion(locationsResult: studentLocations, errorString: nil)
      
    } else {
      completion(locationsResult: nil, errorString: "An error occurred while parsing location data")
    }
  }
}