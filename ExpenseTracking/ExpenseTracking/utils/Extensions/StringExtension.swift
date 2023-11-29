//
//  StringExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

extension String {
    func toDouble(_ numberStyle: NumberFormatter.Style = .decimal, formatter: NumberFormatter = NumberFormatter()) -> Double? {
        formatter.numberStyle = numberStyle
        formatter.locale = .current
        let str = self.replacingOccurrences(of: formatter.groupingSeparator, with: "").replacingOccurrences(of: (Locale.current.currencySymbol ?? ""), with: "")
        return formatter.number(from: str) as? Double
    }
    
    func toDoubleString() -> String {
        guard let numberString = toDouble()?.toStringWithFractionDigits() else {
            return ""
        }
        return numberString
    }
}
