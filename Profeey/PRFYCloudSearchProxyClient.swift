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
    
    // Get top 10 (matchall) users and in location (if provided), sorted by numberOfRecommendations.
    public func getAllUsers(locationName: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationName = locationName {
            queryParameters["q"] = "locationname: '\(locationName)'" as AnyObject?
        } else {
            queryParameters["q"] = "matchall" as AnyObject?
        }
//        queryParameters["q"] = "matchall" as AnyObject?
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // Get users with professionName and in location (if provided), sorted by numberOfRecommendations.
    public func getAllUsersWithProfession(professionName: String, locationName: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        
        let professionNameQ = "professionname: '\(professionName)'"
        
        if let locationName = locationName {
            queryParameters["q"] = "(and \(professionNameQ) locationname: '\(locationName)')" as AnyObject?
        } else {
            queryParameters["q"] = professionNameQ as AnyObject?
        }
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // Get users based on namePrefix (firstName or lastName or preferredUsername) and in location (if provided), sorted by numberOfRecommendations.
    public func getUsers(namePrefix: String, locationName: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        
        let firstNameQ = "(or (prefix field=firstname '\(namePrefix)') firstname: '\(namePrefix)')"
        let lastNameQ = "(or (prefix field=lastname '\(namePrefix)') lastname: '\(namePrefix)')"
        let preferredUsernameQ = "(or (prefix field=preferredusername '\(namePrefix)') preferredusername: '\(namePrefix)')"
        let nameQ = "(or \(firstNameQ) \(lastNameQ) \(preferredUsernameQ))"
        
        if let locationName = locationName {
            queryParameters["q"] = "(and \(nameQ) locationname: '\(locationName)')" as AnyObject?
        } else {
            queryParameters["q"] = nameQ as AnyObject?
        }
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // MARK: Professions
    
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
    
    // Get professions based on namePrefix, sorted by numberOfUsers.
    public func getProfessions(namePrefix: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        
        let professionNameQ = "(or (prefix field=professionname '" + namePrefix + "') professionname: '" + namePrefix + "')"
        
        queryParameters["q"] = professionNameQ as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/professions", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
    
    // MARK: ProfessionsLocations
    
    // Get top 10 (matchall) professions with locationName, sorted by numberOfUsers.
    public func getAllProfessionsLocations(locationName: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "locationname: '\(locationName)'" as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/professions-locations", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
    
    // Get professions based on namePrefix, sorted by numberOfUsers.
    
    // TODO
    public func getProfessionsLocations(namePrefix: String, locationName: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        
        let professionNameQ = "(or (prefix field=professionname '" + namePrefix + "') professionname: '" + namePrefix + "')"
        
        queryParameters["q"] = professionNameQ as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/professions", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
}

