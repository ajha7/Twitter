//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Anshul Jha on 3/1/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var twitterHandleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userArray = [String: Any]()
    var userTweetArray = [NSDictionary]()
    
    var descriptionLabeltext: String = "" {
       didSet {
          descriptionLabel.text = descriptionLabeltext
          descriptionLabel.sizeToFit()
       }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUser()
        loadUserTweets()
        //make table view cell identifier->continue
        // Do any additional setup after loading the view.
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }

    func loadUser() {
        TwitterAPICaller.client?.getUserInfo(success: {
            (userInfo: [String: Any]) in
            self.userArray.removeAll()
            for info in userInfo {
                self.userArray[info.key] = info.value
            }
            let username = self.userArray["name"] as! String
            let twitterHandle = self.userArray["screen_name"] as! String
            let description = self.userArray["description"] as! String
            let createdAt = self.userArray["created_at"] as! String
            let followingCount = self.userArray["friends_count"] as! Int
            let followerCount = self.userArray["followers_count"] as! Int
            
            self.setProfileImage(url: (self.userArray["profile_image_url_https"] as? String)!)
            self.usernameLabel.text = username
            self.twitterHandleLabel.text = "@" + twitterHandle
            self.descriptionLabel.text = description
            self.createdAtLabel.text = "Account created " +  self.getCreatedAtDate(dateString: createdAt)
            self.followingLabel.attributedText = self.getAttributedText(followCount: String(followingCount), regularString: "Following")
            self.followersLabel.attributedText = self.getAttributedText(followCount: String(followerCount), regularString: "Followers")
            
        }, failure: { (Error) in
            print("Failed to get user info")
            print(Error.localizedDescription)
        })
    }
    
    func loadUserTweets() {
        let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        TwitterAPICaller.client?.getUserTweetsRequest(url: url, success: { (userTweets: [NSDictionary]) in
            self.userTweetArray.removeAll()
            for tweet in userTweets {
                self.userTweetArray.append(tweet)
            }
            //print(self.userTweetArray)
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("Could not retrieve user tweets")
            print(Error.localizedDescription)
        })
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setProfileImage(url: String) {
        let imageUrl = URL(string: url)
        let data = try? Data(contentsOf: imageUrl!)
        if let imageData = data {
            profilePicture.image = UIImage(data: imageData)
        }
    }
    
    
    func setUsername(username: String, twitterHandle: String) {
        usernameLabel.text = username
        twitterHandleLabel.text = "@" + twitterHandle
    }
    
    
    func getCreatedAtDate(dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        guard let date = formatter.date(from: dateString) else {
            return "Unable to retrieve date";
            }
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        var month = formatter.string(from: date)
        month = formatter.monthSymbols[Int(month)! - 1]
        
        return month + " " + year
    }
    
    
    func getAttributedText(followCount: String, regularString: String) -> NSAttributedString {
        let boldText = followCount
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        let range = (attributedString.string as NSString).range(of: boldText)
        attributedString.addAttribute(NSMutableAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
        let normalText = " " + regularString
        let normalString = NSMutableAttributedString(string:normalText)
        
        attributedString.append(normalString)
        
        return attributedString
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTweetArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetUserCell", for: indexPath) as! UserTweetCellTableViewCell
        
        let user = userTweetArray[indexPath.row]["user"] as! NSDictionary
       
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetContent.text = userTweetArray[indexPath.row]["text"] as? String
            
        let imageUrl = URL(string: ((user["profile_image_url_https"]) as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(userTweetArray[indexPath.row]["favorited"] as! Bool)
        
        cell.setTweetId(tweetId: userTweetArray[indexPath.row]["id"] as! Int)

        cell.setRetweeted(retweeted: userTweetArray[indexPath.row]["retweeted"] as! Bool)
        
        if #available(iOS 13.0, *) {
            cell.timeLabel.text = getRelativeTime(timeString: (userTweetArray[indexPath.row]["created_at"] as? String)!)
        } else {
            // Fallback on earlier versions
        }
        
       /* let entities = userTweetArray[indexPath.row]["entities"] as! NSDictionary
        let media = ((entities["media"] as? NSArray)?[0] as? NSDictionary)
        if let embeddedImageString = (media?["media_url_https"] as? String) {
            let embeddedImageUrl = URL(string:embeddedImageString)
            let urlData = try? Data(contentsOf: (embeddedImageUrl!))
            if let embeddedImageData = urlData {
                print("embedded")
                print(urlData)
                cell.embeddedImageView.image = UIImage(data: embeddedImageData)
            }
        }*/
        
        return cell
    }

    
    @available(iOS 13.0, *)
    func getRelativeTime(timeString: String) -> String {
        let formatter: RelativeDateTimeFormatter;
        formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        let tweetDate = dateFormatter.date(from:timeString)
        let relativeDate = formatter.localizedString(for: tweetDate!, relativeTo: Date())
        
        return relativeDate
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
