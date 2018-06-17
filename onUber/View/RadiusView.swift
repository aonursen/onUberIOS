//
//  RadiusView.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit

@IBDesignable
class RadiusView: UIView {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

}
