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
import AWSDynamoDB


class PostVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider
    
    let databaseService = DatabaseService()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var imagePost: UIImageView!
    
    @IBOutlet var setMessage: UITextField!
    
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
            displayAlert("Error", message: "Could not process selected image. UIImagePNGRepresentation failed")
            return
        }
        
        let uploadFileUrl = NSURL.fileURLWithPath(location)
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task: AWSS3TransferUtilityTask, progress: NSProgress) in
            print("Progress is: %f", progress.fractionCompleted)
        }
        
        let completionHandler = { (task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error != nil {
                    print("WTF FUCKING FUCK FUCK \(error!)")
                    let alert = UIAlertController(title: "Could not post image", message: "Please try again later", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.savePostToDatabase(S3BucketName, key: S3UploadKeyName)
                }
            })
            } as AWSS3TransferUtilityUploadCompletionHandlerBlock
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.uploadFile(uploadFileUrl, bucket: S3BucketName, key: S3UploadKeyName, contentType: "image/png", expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            if let exception = task.exception {
                print("Error: \(exception.description)")
            }
            if let _ = task.result {
                print("Upload Started...")
            }
            return nil
        }
        

        
    }

    func savePostToDatabase(bucket: String, key: String) {
        let identityId = credentialsProvider.identityId! as String
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let post = Post()
        
        post.id = NSUUID().UUIDString
        post.bucket = bucket
        post.filename = key
        post.userId = identityId
        
        if setMessage.text != nil {
            post.message = self.setMessage.text!
        } else {
            post.message = nil // We can't save a message that is an empty string
        }
        
        mapper.save(post).continueWithBlock { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            
            if let exception = task.exception {
                print("Error: \(exception.description)")
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.displayAlert("Saved", message: "Your post has been saved")
            })
            
            return nil
            
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
    }
}
