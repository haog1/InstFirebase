//
//  FirebaseExtension.swift
//  InsFire
//
//  Created by TG on 7/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import Foundation
import Firebase


extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping(AppUser) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            
            let user = AppUser(uid: uid, dictionary: userDict)
            
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user's username for home feed:", err)
        }
        
    }
}
