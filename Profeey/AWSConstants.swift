//
//  AWSConstants.swift
//  Profeey
//
//  Created by Antonio Zdelican on 07/07/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore

struct AWSConstants {
    
    // MARK: Cognito
    static let COGNITO_REGIONTYPE = AWSRegionType.usEast1
    static let COGNITO_IDENTITY_POOL_ID = "us-east-1:a29f1a34-0cdb-4ad4-b084-2a1a3c165375"
    
    // MARK: UserPool
    static let COGNITO_USER_POOL_ID = "us-east-1_1k48Mmnb3"
    static let COGNITO_USER_POOL_CLIENT_ID = "1d0hdnfmh14d3vsci890rf8sgu"
    static let COGNITO_USER_POOL_CLIENT_SECRET = "1hj5nbbejhd5te6u6r60qm5mi1dlbtsrkv1bo9sq422mfh6jns13"
    
    // MARK: S3
    static let BUCKET_NAME = "profeey-userfiles-mobilehub-294297648"
}
