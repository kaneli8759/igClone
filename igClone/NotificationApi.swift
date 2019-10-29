//
//  NotificationApi.swift
//  igClone
//
//  Created by 李宗政 on 10/23/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import Foundation
import FirebaseDatabase
class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNostification(withId id: String, completion: @escaping (Notification) -> Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newNoti = Notification.transformNotification(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        })
    }
}
