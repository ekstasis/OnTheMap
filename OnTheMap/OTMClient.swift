//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

class OTMClient {
    
    var userID:  String?
    var sessionID: String?
    let urlSession = NSURLSession.sharedSession()
    
    class func sharedInstance() -> OTMClient {
        struct SharedInstance {
            static var sharedInstance = OTMClient()
        }
        return SharedInstance.sharedInstance
    }
    
    func login(userInfo: [String: String], loginHandler: (status: Int?, error: NSError?) -> Void) {
        let body = ["udacity": userInfo]
        let httpBody = try! NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.UdacityMethods.Session.rawValue)!)
        
        request.HTTPBody = httpBody
        
        let task = taskForGetMethod(request, handler: { data, response, error in
            guard error == nil else {
                loginHandler(status: nil, error: error)
                return
            }
            guard let status = (response as? NSHTTPURLResponse)?.statusCode where status >= 200 && status <= 299 else {
                loginHandler(status: (response as! NSHTTPURLResponse).statusCode, error: nil)
                return
            }
        })
    }
    
    func taskForGetMethod(request: NSURLRequest, handler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) -> NSURLSessionTask {
        
    }
}
