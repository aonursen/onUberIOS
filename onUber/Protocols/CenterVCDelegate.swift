//
//  CenterVCDelegate.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit


protocol CenterVCDelegate {
    func toggleLeftPanel()
    func addLeftPanelViewController()
    func animateLeftPanel(shouldExpand: Bool)
}

