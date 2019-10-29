//
//  Api.swift
//  igClone
//
//  Created by 李宗政 on 10/15/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import Foundation
class Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var HashTag = HashTagApi()
    static var Notification = NotificationApi()
}
