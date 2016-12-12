/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at
 
 http://aws.amazon.com/apache2.0
 
 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */


import Foundation
import AWSCore


public class PRFYCloudSearchUsersResultItem : AWSModel {
    
    // not using id because id in DynamoDB is userId
    var id: String?
    
    var userId: String?
    var firstName: String?
    var lastName: String?
    var preferredUsername: String?
    var professionName: String?
    var profilePicUrl: String?
    var locationName: String?
    var numberOfRecommendations: NSNumber?
    
    var professionId: String?
    var locationId: String?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "userId" : "userId",
            "firstName" : "firstName",
            "lastName" : "lastName",
            "preferredUsername" : "preferredUsername",
            "professionName" : "professionName",
            "profilePicUrl" : "profilePicUrl",
            "locationName" : "locationName",
            "numberOfRecommendations" : "numberOfRecommendations",
            "professionId" : "professionId",
            "locationId" : "locationId",
        ]
    }
}
