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
    var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = UIActivityIndicatorView(frame: view.frame)
        indicator.activityIndicatorViewStyle = .WhiteLarge
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopActivityIndicator()
    }
    
    @IBAction func loginButton(sender: UIButton) {
        let user = emailTextField.text!, pass = passwordTextField.text!
        guard !user.isEmpty && !pass.isEmpty else {
            showAlert("Please enter an email address and password.")
            return
        }
        // temporary auto-login
        let userInfo = ["username": user, "password": pass]
        
        client.createSession(userInfo) { userID, sessionID, errorString in
            
            guard errorString == nil else {
                
                //                dispatch_async(dispatch_get_main_queue()) {
                self.showAlert(errorString!)
                self.stopActivityIndicator()
                //                }
                return
            }
            
            self.client.sessionID = sessionID
            self.client.accountKey = userID
            
            self.client.getUserName() { first, last, errorString in
                
                guard errorString == nil else {
                    
                    //                    dispatch_async(dispatch_get_main_queue()) {
                    
                    self.showAlert(errorString!)
                    self.stopActivityIndicator()
                    //                    }
                    
                    return
                }
                
                self.client.firstName = first
                self.client.lastName = last
                
                let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("Main Nav VC") as! UINavigationController
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
        startActivityIndicator()
    }
    
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.indicator.startAnimating()
            for subView in self.view.subviews {
                subView.alpha = 0.3
            }
            self.view.addSubview(self.indicator)
        }
    }
    
    func stopActivityIndicator() {
        dispatch_async(dispatch_get_main_queue()) {
            self.indicator.stopAnimating()
            for subView in self.view.subviews {
                subView.alpha = 1.0
            }
            self.indicator.removeFromSuperview()
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
