//
//  OTMClient Convenience Methods.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/21/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation
import MapKit

/*
* Convenience Methods Extension
*/
extension OTMClient {
  
  func createSession(userInfo: [String: String], loginHandler: (userID: String?, sessionID: String?, errorString: String?) -> Void) {
    
    let body = ["udacity": userInfo]
    
    let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
    
    let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.UdacityMethods.Session.rawValue)!)
    request.HTTPBody = httpBody
    request.HTTPMethod = "POST"
    
    taskForMethod(request) { JSONData, errorString in
      
      guard errorString == nil else {
        loginHandler(userID: nil, sessionID: nil, errorString: errorString)
        return
      }
      
      var sessionJSON: AnyObject
      
      do {
        sessionJSON = try self.JSONObjectFromNSData(self.trimUdacityData(JSONData!))
      } catch let error as NSError {
        loginHandler(userID: nil, sessionID: nil, errorString: error.localizedDescription)
        return
      }
      
      if let udacityError = sessionJSON["error"] as? String {
        loginHandler(userID: nil, sessionID: nil, errorString: udacityError)
        return
      }
      
      let resultDictionary = sessionJSON as? NSDictionary
      let account = resultDictionary?["account"] as? NSDictionary
      let session = resultDictionary?["session"] as? NSDictionary
      let accountKey = account?["key"] as? String
      let sessionID = session?["id"] as? String
      
      guard accountKey != nil && sessionID != nil else {
        loginHandler(userID: nil, sessionID: nil, errorString: "Failed to retrieve user and session from JSON")
        return
      }
      
      loginHandler(userID: accountKey, sessionID: sessionID, errorString: nil)
    }
  }
  
  func deleteSession(handler: (errorString: String?) -> Void) {
    
    let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
    request.HTTPMethod = "DELETE"
    
    var xsrfCookie: NSHTTPCookie? = nil
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    for cookie in sharedCookieStorage.cookies! {
      if cookie.name == "XSRF-TOKEN" {
        xsrfCookie = cookie
      }
    }
    if let xsrfCookie = xsrfCookie {
      request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    
    taskForMethod(request) { data, errorString in
      
      guard errorString == nil else {
        handler(errorString: errorString)
        return
      }
      
      do {
        try self.JSONObjectFromNSData(self.trimUdacityData(data!))
      } catch let error as NSError {
        handler(errorString: error.localizedDescription)
        return
      }
      
      handler(errorString: nil)
    }
  }
  
  func getUserName(loginHandler: (first: String?, last: String?, errorString: String?) -> Void) {
    
    let url = OTMClient.UdacityMethods.User.rawValue + self.accountKey!
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = "GET"
    
    taskForMethod(request) { JSONData, errorString in
      
      guard errorString == nil else {
        loginHandler(first: nil, last: nil, errorString: errorString)
        return
      }
      
      var userJSON: AnyObject
      
      do {
        userJSON = try self.JSONObjectFromNSData(self.trimUdacityData(JSONData!))
      } catch let error as NSError {
        loginHandler(first: nil, last: nil, errorString: error.localizedDescription)
        return
      }
      
      let resultDictionary = userJSON as? NSDictionary
      let userDetails = resultDictionary?["user"] as? NSDictionary
      let firstName = userDetails?["first_name"] as? String
      let lastName = userDetails?["last_name"] as? String
      
      guard firstName != nil && lastName != nil else {
        loginHandler(first: nil, last: nil, errorString: "Failed to retrieve user's name")
        return
      }
      
      loginHandler(first: firstName, last: lastName, errorString: nil)
    }
  }
  
  func getLocations(completion: (locations: [String: AnyObject]?, errorString: String?) -> Void) {
    
    let url = ParseMethods.Locations.rawValue + "?limit=100&order=-updatedAt"
    
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = "GET"
    request.addValue(ParseInfo.ApplicationID.rawValue, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseInfo.APIKey.rawValue, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    taskForMethod(request) { locationsJSON, errorString in
      
      guard errorString == nil else {
        completion(locations: nil, errorString: errorString)
        return
      }
      
      var studentLocations: [String: AnyObject]?
      
      do {
        studentLocations = try self.JSONObjectFromNSData(locationsJSON!) as? [String : AnyObject]
      } catch let error as NSError {
        completion(locations: nil, errorString: error.localizedDescription)
        return
      }
      
      guard studentLocations!["error"] == nil else {
        completion(locations: nil, errorString: "Unable to retrieve locations.")
        return
      }
      
      guard studentLocations != nil else {
        completion(locations: nil, errorString: "The JSON returned from server is not a dictionary")
        return
      }
      
      completion(locations: studentLocations, errorString: nil)
    }
  }
  
  // This function used for both a new location and replacing one
  func postLocation(locationInfo: [String : AnyObject], objectID: String?, completion: (errorString: String?) -> Void) {
    
    let url = ParseMethods.Locations.rawValue + (objectID != nil ? "/\(objectID!)" : "")
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    
    // POST for new location, PUT for replace
    request.HTTPMethod = objectID == nil ? "POST" : "PUT"
    request.addValue(ParseInfo.ApplicationID.rawValue, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseInfo.APIKey.rawValue, forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(locationInfo, options: .PrettyPrinted)
    
    taskForMethod(request) { data, errorString in
      
      guard errorString == nil else {
        completion(errorString: errorString)
        return
      }
      
      var object : [String : AnyObject]?
      
      do {
        object = try self.JSONObjectFromNSData(data!) as? [String : AnyObject]
      } catch {
        completion(errorString: "The data returned from the server is not a dictionary")
        return
      }
      
      if object != nil {
        completion(errorString: nil)
      } else {
        completion(errorString: "The data returned from the server appears to be corrupt")
      }
    }
  }
  
  func checkForPreviousSubmission(completion: (objectID: String?, errorString: String?) -> Void) {
    
    let url = ParseMethods.Locations.rawValue + "?where=%7B%22uniqueKey%22%3A%22\(accountKey!)%22%7D"
    
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    request.HTTPMethod = "GET"
    request.addValue(ParseInfo.ApplicationID.rawValue, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseInfo.APIKey.rawValue, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    taskForMethod(request) { previousSubmissionJSON, errorString in
      
      guard errorString == nil else {
        completion(objectID: nil, errorString: errorString)
        return
      }
      
      var previousSubmission: AnyObject
      
      do {
        previousSubmission = try self.JSONObjectFromNSData(previousSubmissionJSON!)
      } catch let error as NSError {
        completion(objectID: nil, errorString: error.localizedDescription)
        return
      }
      
      let results = (previousSubmission as? [String : AnyObject])?["results"] as? [[String : AnyObject]]
      
      guard results != nil else {
        completion(objectID: nil, errorString: "Invalid JSON while querying previous submission")
        return
      }
      
      if results!.isEmpty {
        completion(objectID: nil, errorString: nil)
      } else {
        let ID = results![0]["objectId"] as? String
        completion(objectID: ID, errorString: nil)
      }
    }
  }
  
  func JSONObjectFromNSData(data: NSData) throws -> AnyObject {
    
    var parsedResult: AnyObject
    
    do {
      parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    } catch {
      throw error
    }
    
    return parsedResult
  }
  
  func trimUdacityData(data: NSData) -> NSData {
    return data.subdataWithRange(NSMakeRange(5, data.length))
  }
}
