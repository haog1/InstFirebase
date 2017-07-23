//
//  CommentCell.swift
//  InsFire
//
//  Created by TG on 20/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    // a reference to comments in commentcontroller
    var comment: Comment? {
        didSet{
            guard let comment = comment else { return }

            let attributedText = NSMutableAttributedString(string: (comment.user.username), attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
            // assigning text into textlabel
            textView.attributedText = attributedText
            
            profileImageView.loadImage(urlString: (comment.user.profileImageUrl))
        }
    }
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(textView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}