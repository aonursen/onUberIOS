//
//  Alert.swift
//  onUber
//
//  Created by Arif Onur Şen on 5.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import Foundation
import UIKit


class Alert {
    class func displayError(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
        return alert
    }
}
