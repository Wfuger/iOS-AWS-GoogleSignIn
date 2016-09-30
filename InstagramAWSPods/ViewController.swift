//
//  ViewController.swift
//  InstagramAWSPods
//
//  Created by Will Fuger on 9/28/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import UIKit
import GoogleSignIn
import AWSCore
import AWSCognito


class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, AWSIdentityProviderManager {
    
    var googleIdToken = ""

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
    
    // SWIFT 3
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if ( error == nil )
//        {
//            googleIdToken = user.authentication.idToken
//            signInToCognito(user: user)
//        }
//        else
//        {
//            print("\(error.localizedDescription)")
//        }
//    }
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error == nil {
            googleIdToken = user.authentication.idToken
            signInToCognito(user)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    func logins() -> AWSTask {
        let result = NSDictionary(dictionary: [AWSIdentityProviderGoogle: googleIdToken])
        return AWSTask(result: result)
    }
    
    func signInToCognito(user: GIDGoogleUser!) {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:6f1a621a-1357-4176-830a-936a633acba5", identityProviderManager: self)
        
        let config = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = config
        
        credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask) -> AnyObject? in
            if task.error != nil {
                print(task.error)
                return nil
            }
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("instagramDataSet")
            
            dataset.setString(user.profile.name, forKey: "name")
            dataset.setString(user.profile.email, forKey: "email")
            
            let result = dataset.synchronize()
            
            result.continueWithBlock({ (task: AWSTask) -> AnyObject? in
                if task.error != nil {
                    print(task.error)
                } else {
                    print(task.result)
                }
                return nil
            })
            return nil
        }
    }
    
    
    // SWIFT 3
//    
//    func signInToCognito(user: GIDGoogleUser!) {
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .usWest2, identityPoolId: "us-west-2:6f1a621a-1357-4176-830a-936a633acba5", identityProviderManager: self)
//        
//        let config = AWSServiceConfiguration(region: .usWest2, credentialsProvider: credentialsProvider)
//        
//        AWSServiceManager.default().defaultServiceConfiguration = config
//        
//        credentialsProvider.getIdentityId().continue( { (task: AWSTask) -> Any? in
//            if task.error != nil {
//                print(task.error)
//                return nil
//            }
//            let syncClient = AWSCognito.default()
//            let dataset = syncClient?.openOrCreateDataset("instagramDataSet")
//            
//            dataset?.setString(user.profile.email, forKey: "email")
//            dataset?.setString(user.profile.name, forKey: "name")
//            
//            let result = dataset?.synchronize()
//            
//            result?.continue({ (task: AWSTask) -> Any? in
//                if task.error != nil {
//                    print(task.error)
//                } else {
//                    print(task.result)
//                }
//                
//                return nil
//            })
//            
//            return nil
//        })

}

