//
//  Comment.swift
//  InsFire
//
//  Created by TG on 21/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import Foundation

struct Comment {
    
    var user: AppUser
    
    let text: String
    let uid: String
    
    
    init(user: AppUser, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
    
}
