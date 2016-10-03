//
//  DatabaseService.swift
//  InstagramAWS
//
//  Created by Will Fuger on 10/3/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import Foundation
import Foundation
import AWSCore
import AWSDynamoDB


class DatabaseService {
    
    func findFollowings(follower: String, map: AWSDynamoDBObjectMapper) -> AWSTask {
        let scan = AWSDynamoDBScanExpression()
        scan.filterExpression = "follower = :val"
        scan.expressionAttributeValues = [":val":follower]
        
        return map.scan(Follower.self, expression: scan).continueWithBlock({ (task: AWSTask) -> AnyObject? in
            if task.error != nil {
                print(task.error)
            }
            if task.exception != nil {
                print(task.exception)
            }
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                return result.items as! [Follower]
            }
            return nil
        })
    }
    
    func findFollower(follower: String, following: String, map: AWSDynamoDBObjectMapper) -> AWSTask {
        let scan = AWSDynamoDBScanExpression()
        scan.filterExpression = "follower = :follower AND following = :following"
        scan.expressionAttributeValues = [":follower":follower, ":following":following]
        
        return map.scan(Follower.self, expression: scan).continueWithBlock({ (task: AWSTask) -> AnyObject? in
            if task.error != nil {
                print(task.error)
            }
            if task.exception != nil {
                print(task.exception)
            }
            if task.result != nil {
                let result = task.result as! AWSDynamoDBPaginatedOutput
                return result.items as! [Follower]
            }
            return nil
        })
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
}
