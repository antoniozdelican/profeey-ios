//
//  PRFYCloudSearchProxyClient.swift
//  Profeey
//
//  Created by Antonio Zdelican on 18/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSAPIGateway

class PRFYCloudSearchProxyClient: AWSAPIGatewayClient {
    
    static let AWSInfoClientKey = "PRFYCloudSearchProxyClient"
    private static let _serviceClients = AWSSynchronizedMutableDictionary()
    
    fileprivate static var sharedInstance: PRFYCloudSearchProxyClient!
    static func defaultClient() -> PRFYCloudSearchProxyClient {
        if sharedInstance == nil {
            sharedInstance = PRFYCloudSearchProxyClient(configuration: AWSServiceManager.default().defaultServiceConfiguration)
        }
        return sharedInstance
    }
    
    init(configuration: AWSServiceConfiguration) {
        super.init()
        
        self.configuration = configuration.copy() as! AWSServiceConfiguration
        var urlString = "https://cd85iyh9d6.execute-api.us-east-1.amazonaws.com/beta"
        if urlString.hasSuffix("/") {
            print(true)
            let stringIndex = urlString.index(urlString.startIndex, offsetBy: urlString.lengthOfBytes(using: String.Encoding.utf8) - 1)
            urlString = urlString.substring(to: stringIndex)
        }
        self.configuration.endpoint = AWSEndpoint(region: configuration.regionType, service: AWSServiceType.apiGateway, url: URL(string: urlString)!)
        let signer: AWSSignatureV4Signer = AWSSignatureV4Signer(credentialsProvider: configuration.credentialsProvider, endpoint: self.configuration.endpoint)
        if let endpoint = self.configuration.endpoint {
            self.configuration.baseURL = endpoint.url
        }
        self.configuration.requestInterceptors = [AWSNetworkingRequestInterceptor(), signer]
    }
    
    /*
     
     @param q
     
     return type: PRFYCloudSearchProfessionsResult
     */
    
    public func rootGet(q: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = q as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
}

