//
//  LogInVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate {
    
    let client = OTMClient.sharedInstance()
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(frame: view.frame)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopActivityIndicator()
    }
    
    @IBAction func loginButton(sender: UIButton) {
        
        let user = emailTextField.text!, pass = passwordTextField.text!
        
//        guard !user.isEmpty && !pass.isEmpty else {
//            showAlert("Please enter an email address and password.")
//            return
//        }
        
//        let userInfo = ["username": user, "password": pass]
        
        // temporary auto-login
        let userInfo = ["username": "straightstory@gmail.com", "password": "ratsoup"]
        
        client.createSession(userInfo) { userID, sessionID, errorString in
            guard errorString == nil else {
                self.showAlert(errorString!)
                self.stopActivityIndicator()
                return
            }
            
            self.client.sessionID = sessionID
            self.client.accountKey = userID
            
            self.client.getUserName() { first, last, errorString in
                guard errorString == nil else {
                    self.showAlert(errorString!)
                    self.stopActivityIndicator()
                    return
                }
                
                self.client.firstName = first
                self.client.lastName = last
                
                let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("Main Nav VC") as! UINavigationController
                
                // If navVC not presented on main queue when the keyboard hasn't been dismissed first
                // causes exception:
                // UIKeyboardTaskQueue waitUntilAllTasksAreFinished] may only be called from the main thread.
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(navVC, animated: true, completion: nil)
                }
            }
        }
        startActivityIndicator()
    }
    
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            for subView in self.view.subviews {
                subView.alpha = 0.3
            }
            self.view.addSubview(self.activityIndicator)
        }
    }
    
    func stopActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            for subView in self.view.subviews {
                subView.alpha = 1.0
            }
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func showAlert(errorString: String) {
        
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        self.stopActivityIndicator()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
