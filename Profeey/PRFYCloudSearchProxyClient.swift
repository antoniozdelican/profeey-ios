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
    class func defaultClient() -> PRFYCloudSearchProxyClient {
        let serviceConfiguration = AWSServiceConfiguration(region: AWSCloudLogicDefaultRegion, credentialsProvider: AWSIdentityManager.defaultIdentityManager().credentialsProvider)
        sharedInstance = PRFYCloudSearchProxyClient(configuration: serviceConfiguration!)
        return sharedInstance
    }
    
    class func registerClientWithConfiguration(configuration: AWSServiceConfiguration, forKey key: NSString){
        self._serviceClients.setObject(PRFYCloudSearchProxyClient(configuration: configuration), forKey: key)
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
    
    // MARK: Users
    
    // Get users based on namePrefix (firstName or lastName or preferredUsername), sorted by numberOfRecommendations.
    public func getUsers(namePrefix: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "(or (prefix field=firstname '" + namePrefix + "') (prefix field=lastname '" + namePrefix + "') (prefix field=preferredusername '" + namePrefix + "'))" as AnyObject?
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // Get top 10 (matchall) users, sorted by numberOfRecommendations.
    public func getAllUsers() -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "matchall" as AnyObject?
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // MARK: Professions
    
    // Get professions based on namePrefix, sorted by numberOfUsers.
    public func getProfessions(namePrefix: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "(prefix field=professionName '" + namePrefix + "')" as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/professions", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
    
    // Get top 10 (matchall) professions, sorted by numberOfUsers.
    public func getAllProfessions() -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "matchall" as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/professions", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
}

