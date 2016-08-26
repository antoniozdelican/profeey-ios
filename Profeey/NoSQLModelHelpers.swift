//
//  NoSQLModelHelpers.swift
//  Profeey
//
//  Created by Antonio Zdelican on 25/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSDynamoDB

let GetItem = "GetItem"
let QueryWithPartitionKey = "QueryWithPartitionKey"
let QueryWithPartitionKeyAndFilter = "QueryWithPartitionKeyAndFilter"
let QueryWithPartitionKeyAndSortKey = "QueryWithPartitionKeyAndSortKey"
let QueryWithPartitionKeyAndSortKeyAndFilter = "QueryWithPartitionKeyAndSortKeyAndFilter"
let Scan = "Scan"
let ScanWithFilter = "ScanWithFilter"

@objc protocol Index {
    var indexName: String? {get}
    
    func supportedOperations() -> [String]
    
    optional func queryWithPartitionKeyDescription() -> String
    
    optional func queryWithPartitionKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    optional func queryWithPartitionKeyAndFilterDescription() -> String
    
    optional func queryWithPartitionKeyAndFilterWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    optional func queryWithPartitionKeyAndSortKeyDescription() -> String
    
    optional func queryWithPartitionKeyAndSortKeyWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    optional func queryWithPartitionKeyAndSortKeyAndFilterDescription() -> String
    
    optional func queryWithPartitionKeyAndSortKeyAndFilterWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
}

@objc protocol Table {
    
    var tableName: String {get set}
    var tableDisplayName: String {get}
    var partitionKeyName: String {get set}
    var partitionKeyType: String {get set}
    var sortKeyName: String? {get set}
    var sortKeyType: String? {get set}
    var model: AWSDynamoDBObjectModel {get set}
    var indexes: [Index] {get set}
    var orderedAttributeKeys: [String] {get}
    
    /**
     * Converts the attribute name from data object format to table format.
     * This should be overriden by each table class.
     *
     * - parameter dataObjectAttributeName: data object attribute name
     * - returns: table attribute name
     */
    optional func tableAttributeName(dataObjectAttributeName: String) -> String
    
    optional func getItemDescription() -> String
    
    optional func getItemWithCompletionHandler(completionHandler: (response: AWSDynamoDBObjectModel?, error: NSError?) -> Void)
    
    optional func scanDescription() -> String
    
    optional func scanWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    optional func scanWithFilterDescription() -> String
    
    optional func scanWithFilterWithCompletionHandler(completionHandler: (response: AWSDynamoDBPaginatedOutput?, error: NSError?) -> Void)
    
    optional func insertSampleDataWithCompletionHandler(completionHandler: (errors: [NSError]?) -> Void)
    
    optional func removeSampleDataWithCompletionHandler(completionHandler: (errors: [NSError]?) -> Void)
    
    optional func updateItem(item: AWSDynamoDBObjectModel, completionHandler: (error: NSError?) -> Void)
    
    optional func removeItem(item: AWSDynamoDBObjectModel, completionHandler: (error: NSError?) -> Void)
    
    optional func produceOrderedAttributeKeys(model: AWSDynamoDBObjectModel)
}

extension Table {
    
    func produceOrderedAttributeKeys(model: AWSDynamoDBObjectModel) -> [String] {
        let keysArray = Array(model.dictionaryValue.keys)
        var keys = keysArray as! [String]
        keys = keys.sort()
        
//        if (model.classForCoder.respondsToSelector("rangeKeyAttribute")) {
//            let rangeKeyAttribute = model.classForCoder.rangeKeyAttribute!()
//            let index = keys.indexOf(rangeKeyAttribute)
//            if let index = index {
//                keys.removeAtIndex(index)
//                keys.insert(rangeKeyAttribute, atIndex: 0)
//            }
//        }
        model.classForCoder.hashKeyAttribute()
        let hashKeyAttribute = model.classForCoder.hashKeyAttribute()
        let index = keys.indexOf(hashKeyAttribute)
        if let index = index {
            keys.removeAtIndex(index)
            keys.insert(hashKeyAttribute, atIndex: 0)
        }
        return keys
    }
}
