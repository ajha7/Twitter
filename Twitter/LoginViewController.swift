//
//  LoginViewController.swift
//  Twitter
//
//  Created by Anshul Jha on 2/21/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (defaults.bool(forKey: "userLoggedIn") == true)
        {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
    }

    @IBAction func onLogin(_ sender: Any) {
        let requestUrl = String("https://api.twitter.com/oauth/request_token")
        defaults.set(true, forKey: "userLoggedIn")
        /*let twitterAPICaller = TwitterAPICaller()
        
        twitterAPICaller.login(url: requestUrl, success: {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }, failure: { (Error) in
            print("Could not login!")
        })*/
        
        
        TwitterAPICaller.client?.login(url: requestUrl, success: {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }, failure: { (Error) in
            print("Could not login!")
        })
        
       
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
