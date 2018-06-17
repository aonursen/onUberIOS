//
//  LeftSidePanelVC.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit
import Firebase

enum accountTypes: String {
    case driver = "DRIVER"
    case passanger = "PASSANGER"
}

class LeftSidePanelVC: UIViewController {
    
    let appDelegate = AppDelegate.getAppDelegate()

    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var pickupText: UILabel!
    @IBOutlet weak var userPhoto: CircleImage!
    @IBOutlet weak var userMail: UILabel!
    @IBOutlet weak var userType: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func hideUserData() {
        userPhoto.isHidden = true
        userType.isHidden = true
        userMail.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchBtn.isHidden = true
        pickupText.isHidden = true
        observePassangerAndDriver()
        if Auth.auth().currentUser == nil {
            hideUserData()
        } else {
            userPhoto.isHidden = false
            userType.isHidden = false
            userMail.isHidden = false
            userMail.text = Auth.auth().currentUser?.email
            signupBtn.setTitle("Logout", for: .normal)
        }
    }
    
    func observePassangerAndDriver() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapShot) in
            if let snapshot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userType.text = accountTypes.passanger.rawValue
                    }
                }
            }
        })
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapShot) in
            if let snapshot = snapShot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if snap.key == Auth.auth().currentUser?.uid {
                        self.userType.text = accountTypes.driver.rawValue
                        self.switchBtn.isHidden = false
                        let switchStatus = snap.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
                        self.switchBtn.isOn = switchStatus
                        if switchStatus {
                            self.pickupText.text = "PICKUP MODE ENABLED"
                        } else {
                            self.pickupText.text = "PICKUP MODE DISABLED"
                        }
                        self.pickupText.isHidden = false
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func switchBtnToggled(_ sender: Any) {
        if switchBtn.isOn {
            pickupText.text = "PICKUP MODE ENABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            DataService.instance.REF_DRIVERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["isPickupModeEnabled": true])
        } else {
            pickupText.text = "PICKUP MODE DISABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            DataService.instance.REF_DRIVERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["isPickupModeEnabled": false])
        }
    }
    @IBAction func signupBtnPressed(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        } else {
            do {
                hideUserData()
                switchBtn.isHidden = true
                pickupText.isHidden = true
                try Auth.auth().signOut()
                signupBtn.setTitle("Sign Up / Login", for: .normal)
            } catch(let error) {
                print(error)
            }
        }
    }
    
}
