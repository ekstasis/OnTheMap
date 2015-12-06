//
//  LogInVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class LogInVC: UIViewController {
    
    let client = OTMClient.sharedInstance()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        ///// necessary?
        loginButton(UIButton.init())
    }
    
    @IBAction func loginButton(sender: UIButton) {
        
        //        guard let user = emailTextField.text, pass = passwordTextField.text else {
        //
        //            // show alert dialog
        //            // return
        //        }
        
        // temporary auto-login
        let userInfo = ["username": "straightstory@gmail.com", "password": "ratsoup"]
        
        client.createSession(userInfo) { userID, sessionID, errorString in
            
            guard errorString == nil else {
                print(errorString)
                return
            }
            
            self.client.sessionID = sessionID
            self.client.accountKey = userID
            print(self.client.sessionID)
            print(self.client.accountKey)
            
            self.client.getUserName() { first, last, errorString in
                
                guard errorString == nil else {
                    print(errorString)
                    return
                }
                
                self.client.firstName = first
                self.client.lastName = last
                print("First: \(self.client.firstName!) - Last: \(self.client.lastName!)")
                
                self.client.update() { errorString in
                    
                    guard errorString == nil else {
                        print(errorString)
                        return
                    }
                    
                    let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("Main Nav VC") as! UINavigationController
                    self.presentViewController(navVC, animated: true, completion: nil)
                }
            }
        }
    }
}
