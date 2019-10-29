//
//  HomeViewController.swift
//  igClone
//
//  Created by 李宗政 on 10/11/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import UIKit
import SDWebImage
class HomeViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var users = [UserModel]()
    var isLoadingPost = false
    let refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        activityIndicatorView.startAnimating()
        
        loadPosts()
    }
    
    @objc func refresh() {
        posts.removeAll()
        users.removeAll()
        loadPosts()
    }
    
    func loadPosts() {
        isLoadingPost = true
        Api.Feed.getRecentFeed(withId: Api.User.CURRENT_USER!.uid, start: posts.first?.timestamp, limit: 100  ) { (results) in
            if results.count > 0 {
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.isLoadingPost = false

            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }

    }
    
    func displayNewPosts(newPosts posts: [Post]) {
        guard posts.count > 0 else {
            return
        }
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for post in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: post, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
    }
    
    
    func fetchUser(uid: String, completed: @escaping () -> Void ) {
        Api.User.observeUsers(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 0
        }
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        if posts.isEmpty {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
           
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true

            guard let lastPostTimestamp = self.posts.last?.timestamp else {
                isLoadingPost = false
                return
            }
            Api.Feed.getOldFeed(withId: Api.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 100) { (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    self.posts.append(result.0)
                    self.users.append(result.1)
                }
                self.tableView.reloadData()

                self.isLoadingPost = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name.init("stopVideo"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name.init("playVideo"), object: nil)

    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}
