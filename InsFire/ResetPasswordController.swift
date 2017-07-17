//
//  ResetPasswordController.swift
//  InsFire
//
//  Created by TG on 15/7/17.
//  Copyright © 2017 TG. All rights reserved.
//
import UIKit
import Firebase

class ResetPasswordController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /***********************************************************************/
    /* set up object classes */
    
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
        tf.placeholder = "Email Authcentication code: "
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let sendEmailCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSendEmailCode), for: .touchUpInside)
        
        button.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        button.isEnabled = false
        
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()

    /***********************************************************************/

    
    /* This function checks if the inputs are in the correct formats */
    func handleTextInputChange() {
        if isValidEmail(testStr: emailTextField.text!) {
            sendEmailCodeButton.isEnabled = true
            sendEmailCodeButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            
            if isPasswordValid(passwordTextField.text!) {
                resetButton.isEnabled = true
                resetButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            }else {
                resetButton.isEnabled = false
                resetButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            }
        } else {
            sendEmailCodeButton.isEnabled = false
            sendEmailCodeButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }

    func handleSendEmailCode() {
        
        // start a timer
        self.sendEmailCodeButton.isEnabled = false
        self.sendEmailCodeButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        self.startTimer()
        
    }
    
    /***********************************************************************/
    /* Set up a timer */

    var countDownTimer = Timer()
    var totalTime = 59

    func startTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    
    func updateTimer() {
        self.sendEmailCodeButton.setTitle("\(totalTime)", for: .normal)
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        totalTime = 59
        self.countDownTimer.invalidate()
        self.sendEmailCodeButton.isEnabled = true
        self.sendEmailCodeButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.sendEmailCodeButton.setTitle("Re-send", for: .normal)
    }
    /***********************************************************************/
    
    func handleReset() {
        
    }

    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14),NSForegroundColorAttributeName:UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /***********************************************************************/
    // load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .white
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        // email and email code send button
        view.addSubview(emailTextField)
        view.addSubview(sendEmailCodeButton)

        emailTextField.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: sendEmailCodeButton.leftAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 5, width: 0, height: 40)
        sendEmailCodeButton.anchor(top: logoContainerView.bottomAnchor, left: emailTextField.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 5, paddingBottom: 0, paddingRight: 40, width: 55, height: 40)
        
        // password and reset button
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)

    }
    
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [passwordTextField, resetButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 90)
    }
}




