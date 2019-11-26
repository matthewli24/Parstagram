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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
   
    // MARK: - Props
    @IBOutlet var tableView: UITableView!
    var posts = [PFObject]()
    var refreshControl = UIRefreshControl()
    var numberOfPosts: Int! = 8
    
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        refreshControl.addTarget(self, action: #selector(getPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        commentBar.inputTextView.placeholder = "Add a comment ..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts(numberOfPosts: numberOfPosts)
        
    }
    
    // MARK: -Private Functions
    
    @objc private func getPosts(numberOfPosts: Int) {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    
    @objc private func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
                 
             let user = post["author"] as! PFUser
             cell.usernameLabel.text = user.username
             cell.captionLabel.text = post["caption"] as? String
             
             let imageFile = post["image"] as! PFFileObject
             let urlString = imageFile.url!
             let url = URL(string: urlString)!

             cell.photoImageView.af_setImage(withURL: url)
             
             return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        
     
    }
       
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            getMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
    
    //MARK: - MessageInputBar Functions
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success {
                print("comment saved")
            } else {
                print("error saving comment")
            }
        }
        
        tableView.reloadData()
        
        // Clear and dismiss
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
    
}
