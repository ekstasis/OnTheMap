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
    
    /////// locations prob not optional, right?
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
                
                self.studentLocations = studentLocations!
                
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
            
//            let status = (response as? NSHTTPURLResponse)?.statusCode
//
//            guard let code = status where code >= 200 && code <= 299 else {
//                handler(JSONData: nil, errorString: "Server responded:  \(status)")
//                return
//            }
            
            if let data = data {
                handler(JSONData: data, errorString: nil)
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
