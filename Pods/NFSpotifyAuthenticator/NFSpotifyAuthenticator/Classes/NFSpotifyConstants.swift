//
//  NFSpotifyConstants.swift
//  Pods
//
//  Created by Neil Francis Hipona on 26/10/2016.
//
//

import Foundation

/// Authorization for access code for token exchange
public let NFSpotifyAutorizationCodeURL: String = "https://accounts.spotify.com/authorize/"

/// Exchange code for token
public let NFSpotifyAutorizationTokenExchangeURL: String = "https://accounts.spotify.com/api/token"

public let NFBaseURLSpotify = "https://api.spotify.com/v1/"

public let NFSpotifyAvailableScopes: [String] = {
    ["playlist-read-private", "playlist-read-collaborative", "playlist-modify-public", "playlist-modify-private", "streaming", "user-follow-modify", "user-follow-read", "user-library-read", "user-library-modify", "user-read-private", "user-read-birthdate", "user-read-email", "user-top-read"]
}()
