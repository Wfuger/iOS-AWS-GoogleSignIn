//
//  PostVC.swift
//  InstagramAWSPods
//
//  Created by Will Fuger on 10/3/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSCognito


class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider
    
    let databaseService = DatabaseService()
    var activityIndicator = UIActivityIndicatorView()
    let S3BucketName = "instagram-project" // 
}

