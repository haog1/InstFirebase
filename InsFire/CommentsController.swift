//
//  CommentsController.swift
//  InsFire
//
//  Created by TG on 20/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase


class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    let cellId = "cellId"
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.hideKeyboardWhenTappedAround()

        navigationItem.title = "Comment"
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
        
    }
    
    var comments = [Comment]()
    
    fileprivate func fetchComments() {
        
        guard let postId = self.post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot.value)
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary)
                // adding comments fetched to the class variable varabile established just above
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
        
        }) { (err) in
            print("failed to observe comments")
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    // dynamic size height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    // every time comments controller is called/presented
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // every time comments controller dispear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // this container holds the input text
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)

        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // input line separator
        let lineSpearatorView = UIView()
        lineSpearatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSpearatorView)
        lineSpearatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    // this calls the container
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter omment"
        textField.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
        return textField
    }()
    
    func handleSubmit() {

        self.view.isUserInteractionEnabled = false
        
        if checkIfValidComment(comment: commentTextField.text!) {
            print("Submitting comments: ", self.post?.id ?? "")
            
            let postId = self.post?.id ?? ""
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
            
            // hide keyboard, scroll to bottom and clear input accessory
            self.commentTextField.text = ""
            self.dismisskeyboard()
            
            let scrollView = UIScrollView()
            scrollView.scrollToBottom()
            
            Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
                
                if let err = err {
                    print(err.localizedDescription)
                    self.showInputWarning(textInput: err.localizedDescription, width: 200, height: 80)
                    return
                }
                
                print("Successfully insert comments into DB")
            }
        }else {
            self.showInputWarning(textInput: "Comment cannot be empty", width: 200, height: 80)
            
        }
        self.view.isUserInteractionEnabled = true
    }
    
    private func checkIfValidComment(comment: String) -> Bool {
        return true
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
