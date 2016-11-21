//
//  AWSCloudSearchManager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 17/11/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    
    func hmac(_ algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(_ result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
    
    func sha256() -> String? {
        guard let messageData = self.data(using:String.Encoding.utf8) else {
            return nil
        }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
//        return digestData.map { String(format: "%02x", $0) }.joined()
    }
    
}

class AWSCloudSearchManager: NSObject {
    
    fileprivate static var sharedInstance: AWSCloudSearchManager!
    static func defaultClientManager() -> AWSCloudSearchManager {
        if sharedInstance == nil {
            sharedInstance = AWSCloudSearchManager()
        }
        return sharedInstance
    }
    
    private func sign(_ key: String, msg: String) -> String {
        return msg.hmac(CryptoAlgorithm.SHA256, key: key)
    }
    
    private func getSignatureKey(_ key: String, dateStamp: String, regionName: String, serviceName: String) -> String {
        let kDate = sign("AWS4" + key, msg: dateStamp)
        let kRegion = sign(kDate, msg: regionName)
        let kService = sign(kRegion, msg: serviceName)
        let kSigning = sign(kService, msg: "aws4_request")
        return kSigning
    }
    
    func get() -> String {
        let method = "GET"
        let service = "cloudsearch"
        let host = "cloudsearch.amazonaws.com"
        let region = "us-east-1"
        let endpoint = "https://cloudsearch.amazonaws.com"
        
        let accessKey = "AWS_ACCESS_KEY_ID"
        let secretKey = "AWS_SECRET_ACCESS_KEY"
        
        let amzDate = Date().amzDate
        let datestamp = Date().datestamp
        
        
        // TASK 1: Create a canonical request
        
        /*
         Step 1: Define the verb (GET, POST, etc.)--already done.
        */
        
        /* 
         Step 2: Create canonical URI--the part of the URI from domain to query string (use '/' if no path)
        */
        let canonicalUri = "/"
        
        /*
         Step 3: Create the canonical headers and signed headers. Header names
         and value must be trimmed and lowercase, and sorted in ASCII order.
         Note trailing \n in canonical_headers.
         signed_headers is the list of headers that are being included
         as part of the signing process. For requests that use query strings,
         only "host" is included in the signed headers.
        */
        let canonicalHeaders = "host:" + host + "\n"
        let signedHeaders = "host"
        
        /*
         Match the algorithm to the hashing algorithm you use, either SHA-1 or SHA-256 (recommended)
        */
        let algorithm = "AWS4-HMAC-SHA256"
        let credentialScope = [datestamp, region, service, "aws4_request"].joined(separator: "/")
        
        /*
         Step 4: Create the canonical query string. In this example, request
         parameters are in the query string. Query string values must
         be URL-encoded (space=%20). The parameters must be sorted by name.
        */
        var canonicalQuerystring = "Action=CreateUser&UserName=NewUser&Version=2013-01-01"
        canonicalQuerystring += "&X-Amz-Algorithm=AWS4-HMAC-SHA256"
        canonicalQuerystring += "&X-Amz-Credential=" + accessKey + "/" + credentialScope
        canonicalQuerystring += "&X-Amz-Date=" + amzDate
//        canonicalQuerystring += "&X-Amz-Expires=30"
        canonicalQuerystring += "&X-Amz-SignedHeaders=" + signedHeaders
        
        /*
         Step 5: Create payload hash. For GET requests, the payload is an empty string ("").
        */
        let payloadHash = "".sha256()!
        
        /*
        Step 6: Combine elements to create create canonical request
        */
        let canonicalRequest = [method, canonicalUri, canonicalQuerystring, canonicalHeaders, signedHeaders, payloadHash].joined(separator: "/")
        
        
        // TASK 2: CREATE THE STRING TO SIGN
        
        let stringToSign = [algorithm, amzDate, credentialScope, canonicalRequest.sha256()!].joined(separator: "\n")
        
        
        // TASK 3: CALCULATE THE SIGNATURE
        
        let signingKey = getSignatureKey(secretKey, dateStamp: datestamp, regionName: region, serviceName: service)
        
        /*
         Sign the string_to_sign using the signing_key
        */
        let signature = stringToSign.hmac(CryptoAlgorithm.SHA256, key: signingKey)
        
        
        // TASK 4: ADD SIGNING INFORMATION TO THE REQUEST
        /*
         The auth information can be either in a query string 
         value or in a header named Authorization. This code shows how to put
         everything into a query string.
        */
        canonicalQuerystring += "&X-Amz-Signature=" + signature
        
        let requestUrl = endpoint + "?" + canonicalQuerystring
        
        return requestUrl
        
    }
}
