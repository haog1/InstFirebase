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
        
        // update feed when a new post shared
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        // register cells for home feeds
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        // refresh controller
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()
    }
    
    
    func handleUpdateFeed() {
        handleRefresh()
    }
    
    // handle refresh
    func handleRefresh() {
        
        // handle unfollowing user refresh
        posts.removeAll()
        fetchAllPosts()
        DispatchQueue.global(qos: .background).async {
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    // reduce duplications
    fileprivate func fetchAllPosts() {
        fetchPost()
        fetchFollowingUserIds()
    }
    
    
    fileprivate func fetchFollowingUserIds() {
        // get the list of following users
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
          
            guard let userIdDict = snapshot.value as? [String: Any] else { return }
            
            userIdDict.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user)
                })
            })

        }) { (err) in
            print("Failed to fetch following user ids: ", err)
        }
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
    
    //ios
    // let refreshControl = UIRefreshControl()
    
    
    fileprivate func fetchPost() {
        
        // gat current user unique ID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
        
    }
    
    // fetch posts from database
    fileprivate func fetchPostsWithUser(user: AppUser) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // stop the refresh icon
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key,value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                let post = Post(user: user, dictionary: dictionary)
                
                self.posts.append(post)
            })
            
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch current user's posts: ", err)
        }
    }
}





