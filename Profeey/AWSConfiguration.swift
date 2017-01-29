//
//  AWSConfiguration.swift
//  Profeey
//
//  Created by Antonio Zdelican on 26/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSCore

#if DEVELOPMENT
    
    // Cognito User Pools Identity Id
    let AWSCognitoUserPoolId: String = "us-east-1_1k48Mmnb3"
        
        // Cognito User Pools App Client Id
    let AWSCognitoUserPoolAppClientId: String = "1d0hdnfmh14d3vsci890rf8sgu"
        
        // Cognito User Pools Region
    let AWSCognitoUserPoolRegion: AWSRegionType = .usEast1
        
        // Cognito User Pools Client Secret
    let AWSCognitoUserPoolClientSecret: String = "1hj5nbbejhd5te6u6r60qm5mi1dlbtsrkv1bo9sq422mfh6jns13"
        
        // Identifier for Cloud Logic API invocation clients
    let AWSCloudLogicDefaultConfigurationKey: String = "CloudLogicAPIKey"
    let AWSCloudLogicDefaultRegion: AWSRegionType = .usEast1
    
#else

    // Cognito User Pools Identity Id
    let AWSCognitoUserPoolId: String = "us-east-1_c7rF5uILU"

    // Cognito User Pools App Client Id
    let AWSCognitoUserPoolAppClientId: String = "4mnce1v79f0udtiirp4fq1l4dn"

    // Cognito User Pools Region
    let AWSCognitoUserPoolRegion: AWSRegionType = .usEast1

    // Cognito User Pools Client Secret
    let AWSCognitoUserPoolClientSecret: String = "7akaev2a4aohe0cn580ksu6s8lp68u4kguio3b5s40m4dc9suon"

    // Identifier for Cloud Logic API invocation clients
    let AWSCloudLogicDefaultConfigurationKey: String = "CloudLogicAPIKey"
    let AWSCloudLogicDefaultRegion: AWSRegionType = .usEast1

#endif
