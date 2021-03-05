//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Anshul Jha on 2/22/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeTableViewController: UITableViewController {
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadTweets()
    }
    
    
    @objc func loadTweets() {
        numberOfTweets = 20
        let homeTweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: homeTweetUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
            print(Error.localizedDescription)
        })
    }
    
    
    func loadMoreTweets() {
        let homeTweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets += 20
        let params = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: homeTweetUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }

            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets")
            print(Error.localizedDescription)
        })
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
            
        let imageUrl = URL(string: ((user["profile_image_url_https"]) as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        
        cell.setTweetId(tweetId: tweetArray[indexPath.row]["id"] as! Int)

        cell.setRetweeted(retweeted: tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        if #available(iOS 13.0, *) {
            cell.timeLabel.text = getRelativeTime(timeString: (tweetArray[indexPath.row]["created_at"] as? String)!)
        } else {
            // Fallback on earlier versions
        }
        
      /*  let entities = tweetArray[indexPath.row]["entities"] as! NSDictionary
        let media = ((entities["media"] as? NSArray)?[0] as? NSDictionary)
        print(user["name"])
        
        if let embeddedImageString = media?["media_url_https"] as? String {
            let embeddedImageUrl = URL(string:embeddedImageString)
            //let urlData = try? Data(contentsOf: (embeddedImageUrl!))
            //if let embeddedImageData = urlData {
            print(embeddedImageUrl)
            cell.embeddedImageView.af_setImage(withURL: embeddedImageUrl!) //= UIImage(data: embeddedImageData)
            //}
        }
        else if let embeddedImageString = entities["url"] as? String {
            let embeddedImageUrl = URL(string:embeddedImageString)
            print (embeddedImageUrl)
            let urlData = try? Data(contentsOf: (embeddedImageUrl!))
            print(urlData)
            if let embeddedImageData = urlData {
                cell.embeddedImageView.image = UIImage(data: embeddedImageData) //= UIImage(data: embeddedImageData)
            }
        }
            */
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count
        {
            loadMoreTweets()
        }
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
}
