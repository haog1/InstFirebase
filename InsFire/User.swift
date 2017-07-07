//
//  User.swift
//  InsFire
//
//  Created by TG on 6/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import Foundation

struct AppUser {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["Username"] as? String ?? ""
        self.profileImageUrl = dictionary["ProfileImageUrl"]  as? String ?? ""
    }
}
