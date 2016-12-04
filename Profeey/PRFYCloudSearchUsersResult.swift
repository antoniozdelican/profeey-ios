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

public class PRFYCloudSearchUsersResult : AWSModel {
    
    var found: NSNumber?
    var start: NSNumber?
    var users: [PRFYCloudSearchUsersResultItem]?
    
   	override public class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        
        return [
            "found" : "found",
            "start" : "start",
            "users" : "users",
        ]
    }
    class func usersJSONTransformer() -> ValueTransformer {
        return  ValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: PRFYCloudSearchUsersResultItem.self);
    }
}
