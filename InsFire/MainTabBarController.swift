//
//  MainTabBarController.swift
//  InsFire
//
//  Created by TG on 30/6/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
 
        let redVC = UIViewController()
        redVC.view.backgroundColor = .white
        
        // flowlayout responsible for auto layout if one row is full, turning to next row
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [navController, UIViewController()]
        
    }
}
