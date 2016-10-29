//
//  NFSpotifyOAuth.swift
//  Pods
//
//  Created by Neil Francis Hipona on 26/10/2016.
//
//

import Foundation
import Alamofire


public class NFSpotifyOAuth: NSObject {
    
    public static let shared = NFSpotifyOAuth()
    
    public var clientID: String!
    public var clientSecret: String!
    public var redirectURI: String!
    public var userDefaultKey: String!

    public var tokenObject: NFSpotifyToken!
    
    private
    override init() {
        super.init()
    }
    
    public func setClientId(_ id: String, clientSecret secret: String, redirectURI uri: String, userDefaultKey key: String! = nil) {
        
        clientID = id
        clientSecret = secret
        redirectURI = uri
        userDefaultKey = key
    }
}

// MARK: - Requests

extension NFSpotifyOAuth {
    
    public func accessTokenFromAccessCode(_ code: String, completion: ((_ tokenObject: NFSpotifyToken?, _ error: Error?) -> Void)? = nil) {
        
        guard let clientID = clientID, let clientSecret = clientSecret, let redirectURI = redirectURI else { return }
        
        let parameters: [String: AnyObject] = ["client_id": clientID as AnyObject, "client_secret": clientSecret as AnyObject, "grant_type": "authorization_code" as AnyObject, "redirect_uri": redirectURI as AnyObject, "code": code as AnyObject]
        
        Alamofire.request(NFSpotifyAutorizationCodeURL, method: .post, parameters: parameters).responseJSON { (response) in
            
            guard let tokenInfo = response.result.value as? [String: AnyObject] else {
                completion?(nil, response.result.error)
                
                return }
            
            if tokenInfo["error"] == nil {
                var accessTokenCreds: [String: AnyObject] = tokenInfo
                
                if let expires_in = tokenInfo["expires_in"]?.doubleValue {
                    let expiryDate = Date(timeIntervalSinceNow: expires_in)
                    accessTokenCreds["expiryDate"] = expiryDate as AnyObject
                }
                
                self.tokenObject = NFSpotifyToken(tokenInfo: accessTokenCreds)
                if let key = self.userDefaultKey {
                    let archivedCreds = NSKeyedArchiver.archivedData(withRootObject: self.tokenObject)
                    UserDefaults.standard.set(archivedCreds, forKey: key)
                    UserDefaults.standard.synchronize()
                }
                
                completion?(self.tokenObject, nil)
            }else{
                self.processError(responseData: tokenInfo, error: response.result.error, completion: completion)
            }
        }
    }
    
    public func renewAccessToken(fromRefreshToken token: String, completion: ((_ tokenObject: NFSpotifyToken?, _ error: Error?) -> Void)? = nil) {
        
        guard let clientID = clientID, let clientSecret = clientSecret, let redirectURI = redirectURI else { return }
        
        let parameters: [String: AnyObject] = ["client_id": clientID as AnyObject, "client_secret": clientSecret as AnyObject, "grant_type": "refresh_token" as AnyObject, "refresh_token": token as AnyObject]
        
        Alamofire.request(NFSpotifyAutorizationTokenExchangeURL, method: .post, parameters: parameters).responseJSON { (response) in
            
            guard let tokenInfo = response.result.value as? [String: AnyObject] else { return }
            
            if tokenInfo["error"] == nil {
                var accessTokenCreds: [String: AnyObject] = tokenInfo
                
                if let expires_in = tokenInfo["expires_in"]?.doubleValue {
                    let expiryDate = Date(timeIntervalSinceNow: expires_in)
                    accessTokenCreds["expiryDate"] = expiryDate as AnyObject
                }
                
                if let tokenObject = self.tokenObject {
                    tokenObject.updateToken(tokenInfo: accessTokenCreds)
                }
                
                if let key = self.userDefaultKey {
                    let archivedCreds = NSKeyedArchiver.archivedData(withRootObject: self.tokenObject)
                    UserDefaults.standard.set(archivedCreds, forKey: key)
                    UserDefaults.standard.synchronize()
                }
                
                completion?(self.tokenObject, nil)
            }else{
                self.processError(responseData: tokenInfo, error: response.result.error, completion: completion)
            }
        }
    }
    
    private func processError(responseData response: [String: AnyObject], error: Error?, completion: ((_ tokenObject: NFSpotifyToken?, _ error: Error?) -> Void)? = nil) {
        
        if let errorInfo = response["error"] as? [String: AnyObject], let code = errorInfo["code"]?.integerValue, let message = ["message"] as? String {
            
            let error = NFSpotifyOAuth.createCustomError(code: code, errorMessage: message)
            
            print("renew access token error: \(error)")
            completion?(nil, error)
        }else if let errorInfo = response["error"] as? String, let errorDesc = response["error_description"] as? String {
            let error = NFSpotifyOAuth.createCustomError(userInfo: ["error": errorInfo, "description": errorDesc])
            
            print("renew access token error: \(response)")
            completion?(nil, error)
        }else if let error = error {
            
            print("renew access token error: \(error)")
            completion?(nil, error)
        }else{
            let error = NFSpotifyOAuth.createCustomError(errorMessage: "Unknown Error")
            
            print("renew access token error: \(error)")
            completion?(nil, error)
        }
    }
}

extension NFSpotifyOAuth {
    
    // MARK: - Error
    
    public class func createCustomError(withDomain domain: String = "com.nf-spotify-o-auth.error", code: Int = 4776, userInfo: [AnyHashable: Any]?) -> Error {
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    public class func createCustomError(withDomain domain: String = "com.nf-spotify-o-auth.error", code: Int = 4776, errorMessage msg: String) -> Error {
        
        return NSError(domain: domain, code: code, userInfo: ["message": msg])
    }
    
}
