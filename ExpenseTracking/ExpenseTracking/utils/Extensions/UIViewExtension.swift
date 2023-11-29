//
//  UIViewExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            self.layer.cornerRadius
        }
    }
}
