//
//  User.swift
//  InstagramAWSPods
//
//  Created by Will Fuger on 9/29/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

class User: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var id = ""
    var name = ""
    var email = ""
    
    override init!() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: ()) throws {
        super.init()
        id = dictionaryValue["id"] as! String
        name = dictionaryValue["name"] as! String
        email = dictionaryValue["email"] as! String
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dynamoDBTableName() -> String {
        return "Users"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
}
