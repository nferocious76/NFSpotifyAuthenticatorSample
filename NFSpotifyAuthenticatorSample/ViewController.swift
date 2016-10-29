//
//  ViewController.swift
//  NFSpotifyAuthenticatorSample
//
//  Created by Neil Francis Hipona on 10/29/16.
//  Copyright © 2016 Neil Francis Hipona. All rights reserved.
//

import UIKit
import NFSpotifyAuthenticator

class ViewController: UIViewController, NFSpotifyLoginViewDelegate {
    
    private var loginView: NFSpotifyLoginView!

    @IBAction func connectButton(_ sender: UIButton) {
        
        loginView.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NFSpotifyOAuth.shared.setClientId("c435e1b830ed4aee9260e8d0e319c7cd", clientSecret: "cee1df07206048a7b665977dd74301c6", redirectURI: "http://api.discovr.fm/callback")
        
        let rectFrame = CGRect(x: 30, y: 80, width: view.frame.width - 60, height: 400)
        loginView = NFSpotifyLoginView(frame: rectFrame, scopes: NFSpotifyAvailableScopes, delegate: self)
        view.addSubview(loginView)
    }
    
}

// MARK: - NFSpotifyLoginViewDelegate

extension ViewController {
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didFailWithError error: Error?) {
        
        print("err: \(error)")
    }
    
    func spotifyLoginView(_ view: NFSpotifyLoginView, didLoginWithTokenObject tObject: NFSpotifyToken) {
        
        print("didLoginWithTokenObject: \(tObject)")

    }

}

