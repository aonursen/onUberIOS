//
//  GradientView.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradientView()
    }
    
    func setupGradientView() {
        gradient.frame = self.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1.0, alpha: 0.0).cgColor]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0.8, 1.0]
        self.layer.addSublayer(gradient)
    }
}
