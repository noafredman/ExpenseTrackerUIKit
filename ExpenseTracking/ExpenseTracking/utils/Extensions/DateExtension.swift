//
//  DateExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

extension Date {
    func toString(dateFormat: String = "dd.MM.yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    static var yesterday: Date {
        Date.now.advanced(by: -60*60*24)
    }
    
    static var today: Date {
        Date.now
    }
    
    static var tomorrow: Date {
        Date.now.advanced(by: 60*60*24)
    }
}
