//
//  Notification.swift
//  igClone
//
//  Created by 李宗政 on 10/23/19.
//  Copyright © 2019 LiTusngCheng. All rights reserved.
//

import Foundation
import FirebaseAuth
class Notification {
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
}
extension Notification {
    static func transformNotification(dict: [String: Any], key: String) -> Notification {
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict["from"] as? String
        return notification
    }
}
