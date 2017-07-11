//
//  SharePhotoController.swift
//  InsFire
//
//  Created by TG on 5/7/17.
//  Copyright © 2017 TG. All rights reserved.
//


import UIKit
import Firebase


class SharePhotoController: UIViewController {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    var selectedImage: UIImage? {
        didSet{
            self.imageView.image = selectedImage
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {

        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
    
        setupImageAndTextViews()
    }
    
    // the image in share screen(view)
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true // let image do not go over the limit bound/size
        return iv
    }()
    
    // text next to the sharing image
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        // add sharing image in the view
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        // add text next to sharing image in the view
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
    /* put all posts into a posts directory, but not root directory
     and save into Firebase Storage
     */
    func handleShare() {
        
        
        guard let caption = textView.text, caption.characters.count > 0 else { return }
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }

        // disable "Share" button immeditately after pressing it
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                // so reset "Share" button once data cannot be sent to firebase
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload posting image: ", err)
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            //print("Successfully uploaded posting image: ", imageUrl)
            print("Successfully uploaded posting image")
            // this time, save information into Firebase Database
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            
        }
    }
    
    // a function that saves posting image and text into DB
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userPostRef = Database.database().reference().child("posts").child(uid)
        
        // generate a location using unique key to form a list of items
        let ref = userPostRef.childByAutoId()
        
        // information that will save into database
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth":postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String: Any] // since this dictionary contains muti data type, so it has to be casted as type: Any
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                // so reset "Share" button once data cannot be sent to firebase
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save posting information into DB: ", err)
            }
            
            print("Successfully saved posting information into DB")
            
            // Sharing window dismiss once all data saved into DB and storage
            // which the userpofile page should show up
            self.dismiss(animated: true, completion: nil)
            
            // handle refresh, posting a signal to homeControlelr
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            
        }
    }
    
}










