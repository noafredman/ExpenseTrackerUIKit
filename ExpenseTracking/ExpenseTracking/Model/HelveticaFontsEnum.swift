//
//  HelveticaFontsEnum.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

enum HelveticaFontsEnum {
    case regular(size: CGFloat)
    case bold(size: CGFloat)
    
    func font() -> UIFont {
        switch self {
            
        case .regular(size: let size), .bold(size: let size):
            return UIFont(name: toString(), size: size) ?? .systemFont(ofSize: size)
        }
    }
    
    private func toString() -> String {
        switch self {
            
        case .regular:
            return "Helvetica"
        case .bold:
            return "Helvetica-Bold"
        }
    }
}

