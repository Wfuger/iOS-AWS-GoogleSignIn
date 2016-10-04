//
//  FeedVC.swift
//  InstagramAWS
//
//  Created by Will Fuger on 10/3/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
import AWSDynamoDB

class FeedTVC: UITableViewController {
    
    var credentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider
    
    let databaseService = DatabaseService()
    var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    
    var imageFiles = [Post]()
    
    func refresh() {
        print("refresh called")
        let identityId = credentialsProvider.identityId! as String
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        imageFiles.removeAll(keepCapacity: true)
        databaseService.findFollowings(identityId, map: mapper).continueWithBlock { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print(error)
            }
            if let exception = task.exception {
                print(exception)
            }
            if task.result != nil {
                for item in task.result as! [Follower] {
                    let result = self.getPosts(item.following, map: mapper)
                    
                    result.continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        let posts = task.result as! [Post]
                        
                        for post in posts {
                            self.imageFiles.append(post)
                        }
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.tableView.reloadData()
                        })
                        return nil
                    })
                }
            }
            return nil
        }
    }

    func getPosts(userId: String, map: AWSDynamoDBObjectMapper) -> AWSTask {
        let scan = AWSDynamoDBScanExpression()
        scan.filterExpression = "userId = :userId"
        scan.expressionAttributeValues = [":userId":userId]
        
        return map.scan(Post.self, expression: scan).continueWithBlock({ (task: AWSTask) -> AnyObject? in
            if let error = task.error {
                print(error)
            }
            if let exception = task.exception {
                print(exception)
            }
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                return result.items as! [Post]
            }
                
            return nil
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        print("view did load")
        refresh()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageFiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = imageFiles[indexPath.row]
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FeedTableViewCell
        
        let currentLocation = self.databaseService.getDocumentsDirectory().stringByAppendingPathComponent(post.filename)
        let manager = NSFileManager.defaultManager()
        
        if(manager.fileExistsAtPath(currentLocation)) {
            myCell.postedimage.image = UIImage(contentsOfFile: currentLocation)
        } else {
            let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
            
            let expression = AWSS3TransferUtilityDownloadExpression()
            expression.progressBlock = {(task: AWSS3TransferUtilityTask, progress: NSProgress) in
                print("Download Progress is: \(progress.fractionCompleted * 100)%")
            }
            self.completionHandler = { (task, location, data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { 
                    myCell.postedimage.image = UIImage(data: data!)
                    
                    if let imageData = UIImagePNGRepresentation(myCell.postedimage.image!) {
                        let location = self.databaseService.getDocumentsDirectory().stringByAppendingPathComponent(post.filename)
                        imageData.writeToFile(location, atomically: true)
                    }
                })
            }
            
            transferUtility.downloadDataFromBucket(post.bucket, key: post.filename, expression: expression, completionHander: completionHandler)
        }
        
        myCell.message.text = post.message != nil ? post.message : ""
        
        return myCell
    }

}
