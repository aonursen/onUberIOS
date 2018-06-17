//
//  LoginVC.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var signBtn: ButtonRadius!
    override func viewDidLoad() {
        emailTF.delegate = self
        passwordTF.delegate = self
        view.bindToKeyboard()
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        if emailTF.text != nil && passwordTF.text != nil {
            signBtn.animateButton(shouldLoad: true, message: nil)
            self.view.endEditing(true)
            if let email = emailTF.text, let password = passwordTF.text {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                let userData = ["provider": user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                            } else {
                                let userData = ["provider": user.providerID,
                                                "userIsDriver": true,
                                                "isPickupModeEnabled": false,
                                                "driverIsOnTrip": false] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .wrongPassword:
                                self.present(Alert.displayError(title: "Password Error", message: "Please enter correct password."), animated: true, completion: nil)
                            default: print(errorCode.rawValue)
                            }
                            self.signBtn.animateButton(shouldLoad: false, message: "Sign Up / Login")
                        }
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                                    switch errorCode {
                                    case .emailAlreadyInUse:
                                        self.present(Alert.displayError(title: "Email Error", message: "This email adready in use."), animated: true, completion: nil)
                                    case .weakPassword:
                                        self.present(Alert.displayError(title: "Weak Password", message: "Please enter a strong password."), animated: true, completion: nil)
                                    case .invalidEmail:
                                        self.present(Alert.displayError(title: "Invalid Email", message: "This email is invalid."), animated: true, completion: nil)
                                        
                                    default: print(errorCode.rawValue)
                                    }
                                    self.signBtn.animateButton(shouldLoad: false, message: "Sign Up / Login")
                                }
                            } else {
                                if let user = user {
                                    if self.segmentedControl.selectedSegmentIndex == 0 {
                                        let userData = ["provider": user.providerID] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                                    } else {
                                        let userData = ["provider": user.providerID,
                                                        "userIsDriver": true,
                                                        "isPickupModeEnabled": false,
                                                        "driverIsOnTrip": false] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                                    }
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
