//
//  XCTestExtension.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import Foundation
import XCTest

extension XCTest {
    func runPerParemeter(_ items: Any..., completion: @escaping (Any) -> ()) {
        for item in items {
            completion(item)
        }
    }
}
