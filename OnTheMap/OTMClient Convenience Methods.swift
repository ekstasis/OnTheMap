//
//  OTMClient Convenience Methods.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/21/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

/*
* Convenience Methods Extension
*/
extension OTMClient {
    
    func createSession(userInfo: [String: String], loginHandler: (userID: String?, sessionID: String?, error: NSError?) -> Void) {
        
        let body = ["udacity": userInfo]
        
        /// factor out?
        let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.UdacityMethods.Session.rawValue)!)
        request.HTTPBody = httpBody
        request.HTTPMethod = "POST"
        
        taskForMethod(request) { JSONData, error in
            
            guard error == nil else {
                // deal with error here instead?
                loginHandler(userID: nil, sessionID: nil, error: error)
                return
            }
            
            let sessionJSON = self.createJSON(self.trimUdacityData(JSONData!))
            
            
            // createJSON returns NSError instead of NSDictionary if it fails
            if let error = sessionJSON as? NSError {
                loginHandler(userID: nil, sessionID: nil, error: error)
            }
            
            let resultDictionary = sessionJSON as? NSDictionary
            let account = resultDictionary?["account"] as? NSDictionary
            let session = resultDictionary?["session"] as? NSDictionary
            let accountKey = account?["key"] as? String
            let sessionID = session?["id"] as? String
            
            guard accountKey != nil && sessionID != nil else {
                let message = [NSLocalizedDescriptionKey: "Failed to retrieve user and session from JSON"]
                let error = NSError(domain: "createSession:", code: 1, userInfo: message)
                
                loginHandler(userID: nil, sessionID: nil, error: error)
                return
            }
            
            // user/account var names need to be normalized
            loginHandler(userID: accountKey, sessionID: sessionID, error: nil)
        }
        
    }
    
    func getUserName(loginHandler: (first: String?, last: String?, error: NSError?) -> Void) {
        
        /*
        * Create URLRequest
        */
        let url = OTMClient.UdacityMethods.User.rawValue + self.accountKey!
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        //        request.HTTPBody = httpBody
        request.HTTPMethod = "GET"
        
        /*
        * taskForMethod Completion Handler
        */
        taskForMethod(request) { JSONData, error in
            
            guard error == nil else {
                // deal with error here instead?
                loginHandler(first: nil, last: nil, error: error)
                return
            }
            
            // Udacity JSON needs first 5 bytes trimmed
            let sessionJSON = self.createJSON(self.trimUdacityData(JSONData!))
            
            // createJSON returns NSError instead of NSDictionary if it fails
            if let error = sessionJSON as? NSError {
                loginHandler(first: nil, last: nil, error: error)
            }
            
            let resultDictionary = sessionJSON as? NSDictionary
            let userDetails = resultDictionary?["user"] as? NSDictionary
            let firstName = userDetails?["first_name"] as? String
            let lastName = userDetails?["last_name"] as? String
            
            guard firstName != nil && lastName != nil else {
                let message = [NSLocalizedDescriptionKey: "Failed to retrieve user and session from JSON"]
                let error = NSError(domain: "createSession:", code: 1, userInfo: message)
                
                loginHandler(first: nil, last: nil, error: error)
                return
            }
            
            loginHandler(first: firstName, last: lastName, error: nil)
        }
    }
    
    func getLocations(completion: (locations: [String: AnyObject]?, error: NSError?) -> Void) {
        
        /*
        * Create URLRequest
        */
        let url = ParseMethods.Location.rawValue + "?limit=100&order=-updatedAt"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        request.addValue(ParseInfo.ApplicationID.rawValue, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseInfo.APIKey.rawValue, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /*
        * taskForMethod Completion Handler
        */
        taskForMethod(request) { locationsJSON, error in
            
            guard error == nil else {
                completion(locations: nil, error: error)
                return
            }
            
            // createJSON returns NSError instead of NSDictionary if it fails
            if let _ = locationsJSON as? NSError {
                completion(locations: nil, error: nil)
            }
            
            let studentLocations = self.createJSON(locationsJSON!)
            
            if let locations = studentLocations as? [String: AnyObject] {
                completion(locations: locations, error: nil)
            } else {
                let message = [NSLocalizedDescriptionKey: "Student locations JSON is invalid"]
                let error = NSError(domain: "OTMClient.getLocations: ", code: 1, userInfo: message)
                
                completion(locations: nil, error: error)
            }
        }
    }
    
    func createJSON(data: NSData) -> AnyObject? {
        
        var parsedResult: AnyObject?
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Couldn't create JSON Object with data: \(data)"]
            let error = NSError(domain: "createJSON", code: 1, userInfo: userInfo)
            return error
        }
        
        return parsedResult
    }
    
    func trimUdacityData(data: NSData) -> NSData {
        return data.subdataWithRange(NSMakeRange(5, data.length))
    }
}
