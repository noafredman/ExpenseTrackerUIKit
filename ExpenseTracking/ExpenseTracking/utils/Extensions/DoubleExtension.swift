//
//  DoubleExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

extension Double {
    func toStringWithFractionDigits(minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 2) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSNumber)
    }
}
