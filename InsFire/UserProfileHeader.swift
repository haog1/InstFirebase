//
//  UserProfileHeader.swift
//  InsFire
//
//  Created by TG on 30/6/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
    func didChangeToBookmarkView()
    func didChangeToEditProfile()
}

class UserProfileHeader: UICollectionViewCell, UIPageViewControllerDelegate {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: AppUser? {
        didSet {
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            setupEditFollowButton()
        }
    }
    
    fileprivate func setupEditFollowButton() {
        
        guard let currLoggdInUser = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        
        if currLoggdInUser == userId {

            editProfileFollowButton.setTitle("Edit Profile", for: .normal)

        } else {
            
            //check if already followed
            Database.database().reference().child("following").child(currLoggdInUser).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
                
            }, withCancel: { (err) in
                print("failed to check if already followed: ", err)
            })

        }
    }
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()

    
    fileprivate func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = .activeColor()
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    /*
     This function creates another node in database which is Follow folder.
     Each signle attribute contains a uid and a list of uesrs who this uid is following to
     */
    func handleEditProfileOrFollow() {
        
        // create a new node
        guard let currLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid  else { return }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            // follow stytling
            Database.database().reference().child("following").child(currLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("failed to unfollow user: ", err)
                    return
                }
                
                print("Successfully unfollow user: ", self.user?.username ?? "")
                self.setupFollowStyle()
            })
        }else if editProfileFollowButton.titleLabel?.text == "Follow" {
            // unfollow styling
            let ref = Database.database().reference().child("following").child(currLoggedInUserId)
            let values = [userId: 1]
            
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user: ", err)
                    return
                }
            }
            print("Successfully followed user: ", self.user?.username ?? "")
            self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
            self.editProfileFollowButton.backgroundColor = .white
            self.editProfileFollowButton.setTitleColor(.black, for: .normal)
        } else{
            print("editing profile")
            delegate?.didChangeToEditProfile()
        }
    }
    

    // the profile image showing on profile page
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    func handleChangeToGridView() {
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = .activeColor()
        delegate?.didChangeToGridView()
    }
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    func handleChangeToListView() {
        listButton.tintColor = .activeColor()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToBookmarkView), for: .touchUpInside)
        return button
    }()
    
    func handleChangeToBookmarkView() {
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        bookmarkButton.tintColor = .activeColor()
        delegate?.didChangeToBookmarkView()
    }
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        //label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /*
     
     initialise the profile header section
     
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setupButtomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        setupUserStatView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    

    /*---------------------------------------------*/
    fileprivate func setupUserStatView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    

    fileprivate func setupButtomToolBar(){
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        let stackView = UIStackView(arrangedSubviews: [gridButton,listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)

        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
