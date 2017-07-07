//
//  User.swift
//  InsFire
//
//  Created by TG on 6/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import Foundation

struct AppUser {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["Username"] as? String ?? ""
        self.profileImageUrl = dictionary["ProfileImageUrl"]  as? String ?? ""
    }
}
