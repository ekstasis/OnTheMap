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
    
    var studentLocations = [StudentInformation]()
    let urlSession = NSURLSession.sharedSession()
    
    class func sharedInstance() -> OTMClient {
        struct SharedInstance {
            static var sharedInstance = OTMClient()
        }
        return SharedInstance.sharedInstance
    }
    
    func update(completion: (error: NSError?) -> Void) {
        getLocations() { locations, error in
            guard error == nil else {
                completion(error: error)
                return
            }
            //// variable names
            self.studentLocations = StudentInformation.arrayFromJSON(locations!)
            print(self.studentLocations[0].fullName + ": " + self.studentLocations[0].updatedAt)
            completion(error: nil)
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
    
    func launchSafariWithURLString(urlString: String) -> Bool {
        
        if let url = NSURL(string: urlString) {
            return UIApplication.sharedApplication().openURL(url)
        } else {
            return false
        }
    }
}
