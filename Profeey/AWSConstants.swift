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
    static let COGNITO_REGIONTYPE = AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "us-east-1:cf413650-369e-477d-bde4-cbc3758e77d9"
    
    // MARK: UserPool
    static let COGNITO_USER_POOL_ID = "us-east-1_Ocb5XvVya"
    static let COGNITO_USER_POOL_CLIENT_ID = "617m2j4ahgmccefsro426l8e75"
    static let COGNITO_USER_POOL_CLIENT_SECRET = "1tn08en453in4en0vh6g1vik6ipnakm8fcg6ijhc90uou2ssd1no"
    
    // MARK: S3
    static let BUCKET_NAME = "profeey-userfiles-mobilehub-1226628658"
}