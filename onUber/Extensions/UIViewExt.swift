//
//  UIViewExt.swift
//  onUber
//
//  Created by Arif Onur Şen on 3.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit


extension UIView {
    func fadeTo(alphaValue: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
}

extension UIViewController {
    func shouldPresentLoading(_ status: Bool) {
        var fadeView: UIView?
        if status {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadeView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            fadeView?.alpha = 0.0
            fadeView?.tag = 99
            
            let spinner = UIActivityIndicatorView()
            spinner.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            spinner.activityIndicatorViewStyle = .whiteLarge
            spinner.center = view.center
            spinner.startAnimating()
            
            view.addSubview(spinner)
            fadeView?.addSubview(spinner)
            spinner.startAnimating()
            fadeView?.fadeTo(alphaValue: 0.7, duration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }, completion: { (finished) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
}
