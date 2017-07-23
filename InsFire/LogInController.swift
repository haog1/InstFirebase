//
//  LogInController.swift
//  InsFire
//
//  Created by TG on 1/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit
import Firebase


class LogInController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        view.addSubview(logoImageView)
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)

        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    func handleTextInputChange() {
        
        if isPasswordValid1(passwordTextField.text!) && isValidEmail(testStr: emailTextField.text!) {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .activeColor()
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .inActiveColor()
        }
    }
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .inActiveColor()
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        button.isEnabled = false
        
        return button
    }()
    
    /*
     this is the fucntion that actually handles sign up and show main screen
     after signning up, which may request to reset UI each time after loggin
     out and signing up a new user or logging in another user
     */

    func handleLogin() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err{
                print("Failed to Sign In: ", err)
                return
            }
            
            // if sign in check successfully: 
            print("Successfully signed in: ", user?.uid ?? "")
            
            // reset UI when anthoer user login
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewController()
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    // dont have account? sign up
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "forgot your password?  ", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Reset Password", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14),NSForegroundColorAttributeName: UIColor.activeColor()]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    func handleResetPassword() {
        let resetPasswordController = ResetPasswordController()
        navigationController?.pushViewController(resetPasswordController, animated: true)
    }
    
    // dont have account? sign up
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14),NSForegroundColorAttributeName: UIColor.activeColor()]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // show sign up statement
    func handleShowSignUp() {
        let signupController = SignUpController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    // change status bar to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
       loading every sub views
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white

        view.addSubview(forgotPasswordButton)
        view.addSubview(dontHaveAccountButton)
        
        // set bottom options, reset password, sign up
        forgotPasswordButton.anchor(top: nil, left: view.leftAnchor, bottom: dontHaveAccountButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        dontHaveAccountButton.anchor(top: forgotPasswordButton.bottomAnchor, left: forgotPasswordButton.leftAnchor, bottom: view.bottomAnchor, right: forgotPasswordButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 20)
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }

}




