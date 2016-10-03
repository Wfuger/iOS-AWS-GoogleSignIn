//
//  Follower.swift
//  InstagramAWS
//
//  Created by Will Fuger on 10/3/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

class Follower: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var id = ""
    var follower = ""
    var following = ""
    
    override init!() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: ()) throws {
        super.init()
        
        if dictionaryValue["id"] != nil {
            id = dictionaryValue["id"] as! String
        }
        if dictionaryValue["follower"] != nil {
            follower = dictionaryValue["follower"] as! String
        }
        if dictionaryValue["following"] != nil {
            following = dictionaryValue["following"] as! String
        }
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dynamoDBTableName() -> String {
        return "Followers"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
}
