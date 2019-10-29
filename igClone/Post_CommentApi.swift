//
//  Post_CommentApi.swift
//  igClone
//
//  Created by 李宗政 on 10/25/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import Foundation
import FirebaseDatabase
class Post_CommentApi {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
}
