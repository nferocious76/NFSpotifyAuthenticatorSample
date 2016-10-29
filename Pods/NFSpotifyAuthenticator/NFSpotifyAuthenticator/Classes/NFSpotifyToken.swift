//
//  NFSpotifyToken.swift
//  Pods
//
//  Created by Neil Francis Hipona on 27/10/2016.
//
//

import Foundation

open class NFSpotifyToken: NSObject {
    
    // MARK: - Declarations
    
    open var token: String!
    open var type: String!
    open var scope: String!
    open var expiry: Double = 0.0
    open var refreshToken: String!
    
    open var expiryDate: Date!
    
    // MARK: - Initializers
    
    private
    override init() {
        super.init()
    }
    
    convenience public init(tokenInfo info: [String: AnyObject]) {
        self.init()
        
        updateToken(tokenInfo: info)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        guard let t = aDecoder.decodeObject(forKey: "token") as? String else { return nil }
        self.init()
        
        token = t
        type = aDecoder.decodeObject(forKey: "type") as? String
        scope = aDecoder.decodeObject(forKey: "scope") as? String
        refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String
        expiryDate = aDecoder.decodeObject(forKey: "expiryDate") as? Date
        
        if let expry = aDecoder.decodeObject(forKey: "expiry"), let seconds = (expry as AnyObject).doubleValue {
            expiry = seconds
        }else{
            expiry = 0
        }
    }
    
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(token, forKey: "token")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(scope, forKey: "scope")
        aCoder.encode(refreshToken, forKey: "refreshToken")
        aCoder.encode(expiry, forKey: "expiry")
        aCoder.encode(expiryDate, forKey: "expiryDate")
    }
}

// MARK: - Controls

extension NFSpotifyToken {
    
    open func updateToken(tokenInfo info: [String: AnyObject]) {
        
        token = info["access_token"] as? String
        type = info["token_type"] as? String
        scope = info["scope"] as? String
        refreshToken = info["refresh_token"] as? String
        
        if let seconds = info["expires_in"]?.doubleValue {
            expiry = seconds
            expiryDate = Date(timeIntervalSinceNow: seconds)
        }else{
            expiry = 0
            expiryDate = Date(timeIntervalSinceNow: 0)
        }
    }
}
