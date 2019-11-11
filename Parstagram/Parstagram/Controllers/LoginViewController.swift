//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Super MattMatt on 11/9/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    // MARK: - Props
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var initialY: CGFloat!
    var offset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Private Functions
    
    private func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
                return
        }
        
        let user = PFUser()
        user.username = username
        user.password = password
        
        
        let errorMessage = "Please Fill In All Fields"
        if username.isEmpty || password.isEmpty {
          showErrorAlert(title: "Cannot Sign Up", message: errorMessage)
        }
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let err = "Error: \(error?.localizedDescription ?? "Error Signing Up")"
                self.showErrorAlert(title: "Error Signing Up", message: err)
            }
        }
    }
    
    @IBAction func onSignInPressed(_ sender: Any) {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else {
                return
        }
        
        let errorMessage = "Please Fill In All Fields"
        if username.isEmpty || password.isEmpty {
            showErrorAlert(title: "Cannot Sign In", message: errorMessage)
        }
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let err = "Error: \(error?.localizedDescription ?? "Error Signing In")"
                self.showErrorAlert(title: "Error Logging In", message: err)
            }
            
        }
    }
    
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    
}
