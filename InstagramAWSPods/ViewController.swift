//
//  ViewController.swift
//  InstagramAWSPods
//
//  Created by Will Fuger on 9/28/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if ( error == nil )
        {
            let idToken = user.authentication.idToken
            let name = user.profile.name
            let email = user.profile.email
            
            print(idToken, name, email)
        }
        else
        {
            print("\(error.localizedDescription)")
        }
    }

}

