//
//  UserProfileController.swift
//  InsFire
//
//  Created by TG on 30/6/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    let homePostCellId = "homePostCellId"
    let cellId = "cellId"
    
    // fetching data from Firebase DB
    var posts = [Post]()
    var user: AppUser?
    var userId: String?
    
    // user profile header switcher
    var isGridView = true
    var isListView = false
    var isBookmark = false
    
    func didChangeToListView() {
        isGridView = false
        isListView = true
        isBookmark = false
        collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        isListView = false
        isBookmark = false
        collectionView?.reloadData()
    }
    
    func didChangeToBookmarkView() {
        isBookmark = true
        isGridView = false
        isListView = false
        collectionView?.reloadData()
    }
    
    func didChangeToEditProfile() {
        print("editing profile from controller")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        // showing the actual id of the user
//        navigationItem.title = Auth.auth().currentUser?.uid
        
        fetchUser()
        
        // register as user profile header
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        setupLogoutButton()
    }
    
    
    fileprivate func fetchOrderedPosts() {
        
        // gat current user unique ID
        
        guard let uid = self.user?.uid else { return }
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        // get data from DB by user's unique ID
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post,at: 0)
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch current users: ", err)
        }
        
    }
    
    
    fileprivate func setupLogoutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                
                try Auth.auth().signOut()
                print("logged out.")
                let loginController = LogInController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
                
            } catch let signOutErr {
                print("Failed to log out:, ", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isListView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            
            cell.post = posts[indexPath.item]
            return cell

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isListView || isBookmark {
            var height: CGFloat = 40 + 8 + 8 // username userporiflleimageview
            height += view.frame.width
            height += 50 // for buttons below the image cell
            height += 80 // for caption text belows than the buttons
            return CGSize(width: view.frame.width, height: height)
        }else {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        header.delegate = self // register custom delegate for UserProfileHeader here
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    fileprivate func fetchUser() {
        
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            
            self.user = user
            self.navigationItem.title = self.user?.username
            
            self.collectionView?.reloadData()
            
            self.fetchOrderedPosts()
        }
    }
}



