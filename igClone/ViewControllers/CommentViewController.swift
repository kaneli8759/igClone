//
//  CommentViewController.swift
//  igClone
//
//  Created by 李宗政 on 10/15/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    
    var postId: String!
    var comments = [Comment]()
    var users = [UserModel]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableView.automaticDimension
        empty()
        handleTextField()
        loadComments()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func loadComments() {
        Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).observe(.childAdded, with: {
            snapshot in
            Api.Comment.observeComments(withPostId: snapshot.key, completion: {
                comment in
                self.fetchUser(uid: comment.uid!, completed: {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void ) {
        Api.User.observeUsers(withId: uid, completion: {
            user in
            self.users.append(user)
            completed()
        })
    }
    
    
    func handleTextField(){
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: .normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: .normal)
        sendButton.isEnabled = false
    }
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        let commentReference = Api.Comment.REF_COMMENTS
        let newCommentId = commentReference.childByAutoId().key
        let newCommentReference = commentReference.child(newCommentId!)
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentReference.setValue(["uid": currentUserId , "commentText": commentTextField.text!], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            
            for var word in words {
                if word.hasPrefix("#") {
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word)
                    let newHashTagPost = [self.postId: true]
                    newHashTagRef.updateChildValues(newHashTagPost)
                }
            }
            
            let postCommentRef = Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).child(newCommentId!)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                Api.Post.observePost(withId: self.postId, completion: { (post) in
                    if post.uid! != Api.User.CURRENT_USER!.uid {
                        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
                        let newNotificationId = Api.Notification.REF_NOTIFICATION.child(post.uid!).childByAutoId().key
                        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(post.uid!).child(newNotificationId!)
                        newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": self.postId!, "type": "comment", "timestamp": timestamp])
                    }
                  
                })
            })
            self.empty()
        })
    }
    
    func empty() {
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Comment_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender as! String
            hashTagVC.tag = tag
        }
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Comment_HashTagSegue", sender: tag)
    }
}
