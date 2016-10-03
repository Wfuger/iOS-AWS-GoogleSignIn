//
//  Post.swift
//  InstagramAWS
//
//  Created by Will Fuger on 10/3/16.
//  Copyright © 2016 BoogieSquad. All rights reserved.
//

import Foundation
import AWSCore
import AWSDynamoDB

class Post: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var id = ""
    var message: String? = nil
    var userId = ""
    var bucket = ""
    var filename = ""
    
    override init!() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: ()) throws {
        super.init()
        
        if dictionaryValue["id"] != nil {
            id = dictionaryValue["id"] as! String
        }
        if dictionaryValue["bucket"] != nil {
            bucket = dictionaryValue["bucket"] as! String
        }
        if dictionaryValue["filename"] != nil {
            filename = dictionaryValue["filename"] as! String
        }
        if dictionaryValue["userId"] != nil {
            userId = dictionaryValue["userId"] as! String
        }
        
        message = dictionaryValue["message"] != nil ? dictionaryValue["message"] as! String : ""
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dynamoDBTableName() -> String {
        return "Posts"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
}
