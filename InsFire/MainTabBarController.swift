//
//  MainTabBarController.swift
//  InsFire
//
//  Created by TG on 30/6/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let logInController = LogInController()
                let navController = UINavigationController(rootViewController: logInController)
                
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupViewController()

    }
    
    func setupViewController() {

        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [navController, UIViewController()]
    }
    
}
