//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Super MattMatt on 11/9/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    // MARK: - Props
    @IBOutlet var tableView: UITableView!
    var posts = [PFObject]()
    var refreshControl = UIRefreshControl()
    var numberOfPosts: Int! = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts(numberOfPosts: numberOfPosts)
        
    }
    
    // MARK: -Private Functions
    
    @objc private func getPosts(numberOfPosts: Int) {
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPosts
        query.order(byDescending: "createdAt") 
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                print("Error: \(error?.localizedDescription ?? "Error Fetching Posts")")
            }
        }
    }
    
    private func getMorePosts() {
        numberOfPosts += 5
        getPosts(numberOfPosts: numberOfPosts)
    }
    
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!

        cell.photoImageView.af_setImage(withURL: url)
        
        return cell
    }
       
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            getMorePosts()
        }
    }

}
