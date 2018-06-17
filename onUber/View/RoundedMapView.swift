//
//  RoundedMapView.swift
//  onUber
//
//  Created by Arif Onur Şen on 9.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit
import MapKit

class RoundedMapView: MKMapView {
    
    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 10.0
    }

}
