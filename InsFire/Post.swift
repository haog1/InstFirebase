//
//  Post.swift
//  InsFire
//
//  Created by TG on 5/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import Foundation

struct Post {
    
    let user: AppUser
    let imageUrl: String
    let caption: String
    
    init(user: AppUser, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
    }
    
}
