//
//  HomeController.swift
//  InsFire
//
//  Created by TG on 6/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
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
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        tap.numberOfTapsRequired = 2
//        view.addGestureRecognizer(tap)
        
    }
    
//    func handleTap() {
//
//    }
    
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    
    // show camera shooting view
    func handleCamera() {
        
        let cameraController = CameraController() // construct an Camera-shooting object from custom class
        
        present(cameraController, animated: true, completion: nil) // show it when the icon is pressed
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
//        print("Posts: ",posts.count)
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }

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
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1{
                        post.hasLiked = true
                    }else {
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                    self.collectionView?.reloadData()


                    
                }, withCancel: { (err) in
                    
                    print("Failed to fetch likes for post: ", err)
                
                })
            })
            
        }) { (err) in
            print("Failed to fetch current user's posts: ", err)
        }
    }

    /*
     Custom Delegation Protocol Function Implementation
     */
    func didTapComment(post: Post) {
        
        print(post.caption)
        
        let commentsController = CommentsController(collectionViewLayout:UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        //print("Liking inside controller Home")
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        
        var post = self.posts[indexPath.item]
        print(post.caption)
        
        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed to like posts: ",err)
                return
            }
            
            print("Successfully liked post")
            
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    
    
}


