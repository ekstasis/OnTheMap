//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation
import UIKit

class OTMClient {
  
  var accountKey:  String?
  var sessionID: String?
  var firstName: String?
  var lastName: String?
  
  let urlSession = NSURLSession.sharedSession()
  
  class func sharedInstance() -> OTMClient {
    struct SharedInstance {
      static var sharedInstance = OTMClient()
    }
    return SharedInstance.sharedInstance
  }
  
  func update(completion: (locations: [StudentInformation]?, errorString: String?) -> Void) {
    
    getLocations() { locations, errorString in
      
      guard errorString == nil else {
        completion(locations: nil, errorString: errorString)
        return
      }
      
      StudentInformation.arrayFromJSON(locations!) { studentLocations, errorString in
        guard errorString == nil else {
          completion(locations: nil, errorString: errorString)
          return
        }
        
        StudentInformation.studentLocations = studentLocations!
        
        completion(locations: studentLocations, errorString: nil)
      }
    }
  }
  
  func taskForMethod(request: NSMutableURLRequest, handler: (JSONData: NSData?, errorString: String?) -> Void) {
    
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = self.urlSession.dataTaskWithRequest(request) { data, response, error in
      
      guard error == nil else {
        handler(JSONData: nil, errorString: error!.localizedDescription)
        return
      }
      
      if let data = data {
        handler(JSONData: data, errorString: nil)
      }
    }
    
    task.resume()
  }
  
}
