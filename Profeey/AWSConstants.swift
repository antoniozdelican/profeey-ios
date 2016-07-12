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
    static let COGNITO_USER_POOL_ID = "us-east-1_vNnDm9MzS"
    static let COGNITO_USER_POOL_CLIENT_ID = "76a091o548cr1fmoobq309gjqp"
    static let COGNITO_USER_POOL_CLIENT_SECRET = "fvkarnop5fq563qlgs53haa339od5is9gdbf890tofg41ss0c0q"
    
    // MARK: DynamoDB
    static let EMPTY_STRING_CONSTANT = " "
}