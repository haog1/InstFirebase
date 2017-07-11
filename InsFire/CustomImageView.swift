//
//  CustomImageView.swift
//  InsFire
//
//  Created by TG on 5/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit

// global varible
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    /* function avoid duplicated code and load images from DB */
    func loadImage(urlString: String) {
        
        lastURLUsedToLoadImage = urlString
        self.image = nil
        
        // caching image
        if let cachedImage = imageCache[urlString] {

            self.image = cachedImage
            return
        }
        
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let err = err {
                print("Failed to fetch posts to show on user profile page: ", err)
            }
            
            // prevent loading image in incorrect order or repeating showing the same photo
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()
        
    }
}
