//
//  ViewController.swift
//  planify
//
//  Created by Olof Enström on 2018-07-13.
//  Copyright © 2018 Olof Enström. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInButtonPressed(_ sender: Any) {
        let appURL = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
         let webURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()!
        
        // Before presenting the view controllers we are going to start watching for the notification
        NotificationCenter.default.addObserver(self, selector: #selector(receievedUrlFromSpotify(_:)), name: NSNotification.Name.Spotify.authURLOpened, object: nil)
        
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(appURL!, options: [:], completionHandler: nil)
        } else {
            present(SFSafariViewController(url: webURL), animated: true, completion: nil)
        }
    }
    
    @objc func receievedUrlFromSpotify(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
        
        SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { (error, session) in
            //Check if there is an error because then there won't be a session.
            if let error = error {
                print(error)
                print("yikes")
                print("tried with")
                print(SPTAuth.defaultInstance().clientID)
                return
            }
            
            // Check if there is a session
            if let session = session {
                // If there is use it to login to the audio streaming controller where we can play music.
                print("there is a session")
                SPTAudioStreamingController.sharedInstance().login(withAccessToken: session.accessToken)
                SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:7cQnIhLin7koR2sO2bt2KS", startingWith: 0, startingWithPosition: 0, callback: { (error) in
                    if (error != nil) {
                        print("playing!")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
            self.performSegue(withIdentifier: "segueLogIn", sender: self)
                
            }
        }
    }
    
}

