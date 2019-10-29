//
//  CommentApi.swift
//  igClone
//
//  Created by 李宗政 on 10/15/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import Foundation
import FirebaseDatabase
class CommentApi {
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void){
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
            let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }
        })
    }
}
