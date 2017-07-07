//
//  HomeController.swift
//  InsFire
//
//  Created by TG on 6/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var posts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        // register cells for home feeds
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationItems()
        fetchPost()
        
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        // get posts showed on home feed
    }
    
    
    /* this function sets each cell a screen width and 200 height, which makes every cell stands alone in the row
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 // username userporiflleimageview
        height += view.frame.width
        height += 50 // for buttons below the image cell
        height += 80 // for caption text belows than the buttons
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    fileprivate func fetchPost() {
        
        // gat current user unique ID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // fetching username
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            
            let user = AppUser(dictionary: userDict)
            // get data from DB by user's unique ID
            
            let ref = Database.database().reference().child("posts").child(uid)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key,value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    let post = Post(user: user, dictionary: dictionary)
                    
                    self.posts.append(post)
                })
                
                self.collectionView?.reloadData()
                
            }) { (err) in
                print("Failed to fetch current user's posts: ", err)
            }
            
        }) { (err) in
            print("Failed to fetch user's username for home feed:", err)
        }
    }
    
    
}
