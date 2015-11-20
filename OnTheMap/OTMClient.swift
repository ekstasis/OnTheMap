//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

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
    
    func createSession(userInfo: [String: String], loginHandler: (userID: String?, sessionID: String?, error: NSError?) -> Void) {
        
        let body = ["udacity": userInfo]
        
        /// factor out?
        let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.UdacityMethods.Session.rawValue)!)
        request.HTTPBody = httpBody
        request.HTTPMethod = "POST"
        
        /// better names for "JSONData" etc.
        taskForMethod(request) { JSONData, error in
            
            guard error == nil else {
                // deal with error here instead?
                loginHandler(userID: nil, sessionID: nil, error: error)
                return
            }
            
            let sessionJSON = self.createJSON(self.trimUdacityData(JSONData!))
            
            // createJSON return NSError instead of NSDictionary if it fails
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
        
        // Returned JSON example from call:
        //        {
        //            "account":{
        //                "registered":true,
        //                "key":"3903878747"
        //            },
        //            "session":{
        //                "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
        //                "expiration":"2015-05-10T16:48:30.760460Z"
        //            }
        //        }
    }
    
    func getUserName(loginHandler: (first: String?, last: String?, error: NSError?) -> Void) {
        
        /// factor out?
//        let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        let url = OTMClient.UdacityMethods.User.rawValue + self.accountKey!
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
//        request.HTTPBody = httpBody
        request.HTTPMethod = "GET"
        
        /// better names for "JSONData" etc.
        taskForMethod(request) { JSONData, error in
            
            guard error == nil else {
                // deal with error here instead?
                loginHandler(first: nil, last: nil, error: error)
                return
            }
///// var name
            let sessionJSON = self.createJSON(self.trimUdacityData(JSONData!))
            
            // createJSON return NSError instead of NSDictionary if it fails
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
    
    func taskForMethod(request: NSMutableURLRequest, handler: (JSONData: NSData?, error: NSError?) -> Void) {
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = urlSession.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                // deal with error here?
                handler(JSONData: nil, error: error)
                return
            }
           
            let status = (response as? NSHTTPURLResponse)?.statusCode
            
            guard let code = status where code >= 200 && code <= 299 else {
                print("HTTP Response Error:  \(status)")
                return
            }
            
            if let data = data {
                handler(JSONData: data, error: nil)
            }
        }
        
        task.resume()
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
