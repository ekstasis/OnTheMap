//
//  ClientConstantsExtension.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/9/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import Foundation

extension OTMClient {
    
    enum UdacityMethods: String {
        case Session = "https://www.udacity.com/api/session"
        case User = "https://www.udacity.com/api/users/" // plus <userID>
    }
    
    enum ParseMethods: String {
        case Locations = "https://api.parse.com/1/classes/StudentLocation"
        case Object = "https://api.parse.com/1/classes/StudentLocation/<objectID>"
    }
    
    enum ParseInfo: String {
        case ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        case APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
}
        