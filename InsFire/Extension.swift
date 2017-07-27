//
//  Extension.swift
//  InsFire
//
//  Created by TG on 30/6/17.
//  Copyright © 2017 TG. All rights reserved.
//
import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    static func activeColor() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
    static func inActiveColor() -> UIColor {
        return UIColor.rgb(red: 149, green: 204, blue: 244)
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismisskeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismisskeyboard() {
        view.endEditing(true)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func isUsernameValid(username: String) -> Bool {
        var isAllBlank = false
        if username.characters.count > 2 {
            for char in username.characters {
                if char == " " {
                    isAllBlank = true
                    break
                }
            }
        } else {
            return false
        }
        
        if isAllBlank {
            return false
        }else {
            return true
        }
    }
    
    func isPasswordValid1(_ password : String) -> Bool{
        if password.characters.count > 1 {
            return true
        }else {
            return false
        }
    }
    
    func areEqualImages(img1: UIImage, img2: UIImage) -> Bool {
        
        guard let data1 = UIImagePNGRepresentation(img1) else { return false }
        guard let data2 = UIImagePNGRepresentation(img2) else { return false }
        
        return data1 == data2
    }
    
    
    func showInputWarning(textInput: String, width: CGFloat, height: CGFloat) {
        
        DispatchQueue.main.async {
            let label = UILabel()
            label.text = textInput
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = .white
            label.numberOfLines = 0
            label.backgroundColor = UIColor(white: 0, alpha: 0.3)
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: 0, width: width, height: height)

            self.view.addSubview(label)
            label.layer.transform = CATransform3DMakeScale(0, 0, 0)
            self.view.bringSubview(toFront: label)
            label.center = self.view.center
            
            // fade in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                label.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: { (completed) in
                
                // fade out
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    label.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    label.alpha = 0
                }, completion: { (_) in
                    label.removeFromSuperview()
                })
            })
        }
    }
    
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
        
}

extension UIScrollView {
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}







