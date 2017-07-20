//
//  CommentsController.swift
//  InsFire
//
//  Created by TG on 20/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase


class CommentsController: UICollectionViewController {
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()

        navigationItem.title = "Comment"
        
        collectionView?.backgroundColor = .red
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
        return containerView
    }()
    
    // this calls the container
    override var inputAccessoryView: UIView? {
        get {
            self.hideKeyboardWhenTappedAround()
            return containerView
        }
    }
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter omment"
        return textField
    }()
    
    func handleSubmit() {
        print("Submitting comments: ", self.post?.id ?? "")
        
        let postId = self.post?.id ?? ""
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed upload comments into DB: ", err)
            }

            print("Successfully insert comments into DB")
            
        }
        
        
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
