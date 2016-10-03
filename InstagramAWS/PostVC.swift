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
import AWSS3


class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider
    
    let databaseService = DatabaseService()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var imagePost: UIImageView!
    
    @IBOutlet weak var setMessage: UITextField!
    
    @IBAction func chooseImage(sender: AnyObject) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        imagePost.image = chosenImage
    }
    
    @IBAction func postImage(sender: AnyObject) {
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let S3UploadKeyName = NSUUID().UUIDString + ".png"
        var location = ""
        
        if let data = UIImagePNGRepresentation(self.imagePost.image!) {
            location = databaseService.getDocumentsDirectory().stringByAppendingPathComponent(S3UploadKeyName)
            data.writeToFile(location, atomically: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Could not process selected image. UIImagePNGRepresentation failed.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let uploadFileUrl = NSURL.fileURLWithPath(location)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task: AWSS3TransferUtilityTask, progress: NSProgress) in
         print("Progress is: %f", progress.fractionCompleted)
        }
        
//        let completionHandler = { (task, error) -> Void in
//            dispatch_async(dispatch_get_main_queue(), { 
//                self.activityIndicator.stopAnimating()
//                UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                
//                if error != nil {
//                    print(error)
//                    let alert = UIAlertController(title: "Could not post image", message: "Please try again later", preferredStyle: .Alert)
//                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
//                    alert.addAction(okAction)
//                    self.presentViewController(alert, animated: true, completion: nil)
//                } else {
//                    self.savePostToDatabase()
//                }
//            })
//        }
        
        
    }
    
    
}
