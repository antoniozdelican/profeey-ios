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
    
    // Get top 10 (matchall) users in location (if provided), sorted by numberOfRecommendations.
    public func getAllUsers(locationId: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationId = locationId {
            queryParameters["q"] = "locationid: '\(locationId)'" as AnyObject?
        } else {
            queryParameters["q"] = "matchall" as AnyObject?
        }
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // Get users with professionId in location (if provided), sorted by numberOfRecommendations.
    public func getAllUsersWithProfession(professionId: String, locationId: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        let professionIdQ = "professionid: '\(professionId)'"
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationId = locationId {
            queryParameters["q"] = "(and \(professionIdQ) locationid: '\(locationId)')" as AnyObject?
        } else {
            queryParameters["q"] = professionIdQ as AnyObject?
        }
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // Get users based on namePrefix (firstName or lastName or preferredUsername) and in location (if provided), sorted by numberOfRecommendations.
    public func getUsers(namePrefix: String, locationId: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        let firstNameQ = "(or (prefix field=firstname '\(namePrefix)') firstname: '\(namePrefix)')"
        let lastNameQ = "(or (prefix field=lastname '\(namePrefix)') lastname: '\(namePrefix)')"
        let preferredUsernameQ = "(or (prefix field=preferredusername '\(namePrefix)') preferredusername: '\(namePrefix)')"
        let nameQ = "(or \(firstNameQ) \(lastNameQ) \(preferredUsernameQ))"
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationId = locationId {
            queryParameters["q"] = "(and \(nameQ) locationid: '\(locationId)')" as AnyObject?
        } else {
            queryParameters["q"] = nameQ as AnyObject?
        }
        queryParameters["sort"] = "numberofrecommendations desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/users", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchUsersResult.self)
    }
    
    // MARK: Professions
    
    // Get top 10 (matchall) professions in location (if provided), sorted by numberOfUsers.
    public func getAllProfessions(locationId: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationId = locationId {
            queryParameters["q"] = "locationid: '\(locationId)'" as AnyObject?
        } else {
            queryParameters["q"] = "matchall" as AnyObject?
        }
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        let pathParameters: [String:AnyObject] = [:]
        
        // professions-locations-domain or professions-domain
        let urlString = (locationId != nil) ? "/professions-locations" : "/professions"
        
        return self.invokeHTTPRequest("GET", urlString: urlString, pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
    
    // Get professions based on namePrefix and in location (if provided), sorted by numberOfUsers.
    public func getProfessions(namePrefix: String, locationId: String?) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        let professionNameQ = "(or (prefix field=professionname '\(namePrefix)') professionname: '\(namePrefix)')"
        
        var queryParameters: [String:AnyObject] = [:]
        if let locationId = locationId {
            queryParameters["q"] = "(and \(professionNameQ) locationid: '\(locationId)')" as AnyObject?
        } else {
            queryParameters["q"] = professionNameQ as AnyObject?
        }
        queryParameters["q"] = professionNameQ as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        let pathParameters: [String:AnyObject] = [:]
        
        // professions-locations-domain or professions-domain
        let urlString = (locationId != nil) ? "/professions-locations" : "/professions"
        
        return self.invokeHTTPRequest("GET", urlString: urlString, pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchProfessionsResult.self)
    }
    
    // MARK: Locations
    
    // Get 10 (matchall) locations.
    public func getAllLocations() -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = "matchall" as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
        queryParameters["q.parser"] = "structured" as AnyObject?
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/locations", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchLocationsResult.self)
    }
    
    // Get locations based on namePrefix (country or state or city).
    public func getLocations(namePrefix: String) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            
            ]
        
        // Using simple parser.
//        let countryQ = "(or (prefix field=country '\(namePrefix)') country: '\(namePrefix)')"
//        let stateQ = "(or (prefix field=state '\(namePrefix)') state: '\(namePrefix)')"
//        let cityQ = "(or (prefix field=city '\(namePrefix)') city: '\(namePrefix)')"
//        let nameQ = "(or \(countryQ) \(stateQ) \(cityQ))"
        let nameQ = "(\(namePrefix)*)"
        
        var queryParameters: [String:AnyObject] = [:]
        queryParameters["q"] = nameQ as AnyObject?
        queryParameters["sort"] = "numberofusers desc" as AnyObject?
//        queryParameters["q.parser"] = "structured" as AnyObject?
        queryParameters["q.parser"] = "simple" as AnyObject?
        
        let pathParameters: [String:AnyObject] = [:]
        
        return self.invokeHTTPRequest("GET", urlString: "/locations", pathParameters: pathParameters, queryParameters: queryParameters, headerParameters: headerParameters, body: nil, responseClass: PRFYCloudSearchLocationsResult.self)
    }
}

