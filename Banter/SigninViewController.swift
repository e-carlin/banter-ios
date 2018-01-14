//
//  SignInViewController.swift
//  Banter
//
//  Created by e-carlin on 1/2/18.
//  Copyright © 2018 Banter. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.emailTextField.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.signInButton.isEnabled = true
    }
    
    @IBAction func SignInPressed(_ sender: AnyObject) {
        guard let emailAddress = self.emailTextField.text, !emailAddress.isEmpty,
        let password = self.passwordTextField.text, !password.isEmpty else {
            let alertController = UIAlertController(title: "Sign In Error", message: "Please make sure you supply a valid email and password.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            return
            
            
        }
        signInButton.isEnabled = false
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.emailTextField.text!, password: self.passwordTextField.text! )
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    @IBAction func SignUpPressed(_ sender: AnyObject) {
        self.shouldPerformSegue(withIdentifier: "signUpSegue", sender: self)
    }
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.signInButton.isEnabled = true
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.emailTextField.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
