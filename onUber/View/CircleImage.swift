//
//  CircleImage.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setCircle()
    }
    
    func setCircle() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setCircle()
    }
}
