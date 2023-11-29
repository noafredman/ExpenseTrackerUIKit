//
//  UIApplicationExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman on 30/11/2023.
//

import Foundation
import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow

    }
}
