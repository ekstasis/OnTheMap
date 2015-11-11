//
//  LogInVC.swift
//  OnTheMap
//
//  Created by Ekstasis on 11/8/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

class LogInVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginButton(sender: UIButton) {
        
        guard let user = emailTextField.text, pass = passwordTextField.text else {
            //////////////////     show alert dialog
            return
        }
        
        let userInfo = ["username": user, "password": pass]
        
        OTMClient.sharedInstance().login(userInfo) { status, error in
            guard error == nil else {
                ////////////////   deal with error
                return
            }
            let navVC = self.storyboard?.instantiateViewControllerWithIdentifier("Main Nav VC") as! UINavigationController
            self.presentViewController(navVC, animated: true, completion: nil)
        }
        
    }
}
