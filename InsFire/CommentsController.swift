//
//  CommentsController.swift
//  InsFire
//
//  Created by TG on 20/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit

class CommentsController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override var inputAccessoryView: UIView? {
        get {
            let containerView = UIView()
            containerView.backgroundColor = .white
            containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}
