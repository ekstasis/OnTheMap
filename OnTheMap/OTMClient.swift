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
    
    let urlSession = NSURLSession.sharedSession()
    
    class func sharedInstance() -> OTMClient {
        struct SharedInstance {
            static var sharedInstance = OTMClient()
        }
        return SharedInstance.sharedInstance
    }
    
    func createSession(userInfo: [String: String], loginHandler: (error: NSError?) -> Void) {
        
        let body = ["udacity": userInfo]
        let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.UdacityMethods.Session.rawValue)!)
        request.HTTPBody = httpBody
        
        taskForPostMethod(request) { JSONData, error in
            
            guard error == nil else {
                // deal with error here instead?
                loginHandler(error: error)
                return
            }
            
            let JSONData = JSONData!.subdataWithRange(NSMakeRange(5, JSONData!.length))
            let JSONObject = self.createJSON(JSONData)
            
            if let error = JSONObject as? NSError {
                loginHandler(error: error)
            }
            
            let resultDictionary = JSONObject as? NSDictionary
            let account = resultDictionary?["account"] as? NSDictionary
            let session = resultDictionary?["session"] as? NSDictionary
            let accountKey = account?["key"] as? String
            let sessionID = session?["id"] as? String
            
            guard accountKey != nil || sessionID != nil else {
                let message = [NSLocalizedDescriptionKey: "Failed to retrieve user and session from JSON"]
                let error = NSError(domain: "createSession:", code: 1, userInfo: message)
                
                loginHandler(error: error)
                return
            }
            
            self.accountKey = accountKey
            self.sessionID = sessionID
            
            print(self.sessionID)
            print(self.accountKey)
            
            loginHandler(error: nil)
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
    
    func taskForPostMethod(request: NSMutableURLRequest, handler: (JSONData: NSData?, error: NSError?) -> Void) {
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
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
        
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(dataString)
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Couldn't create JSON Object with data: \(data)"]
            let error = NSError(domain: "createJSON", code: 1, userInfo: userInfo)
            
            return error
        }
        
        return parsedResult
    }
}
