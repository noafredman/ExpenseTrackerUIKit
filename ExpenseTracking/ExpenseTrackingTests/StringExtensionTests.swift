//
//  StringExtensionTests.swift
//  ExpenseTrackingTests
//
//  Created by Noa Fredman.
//

import XCTest
@testable import ExpenseTracking

final class StringExtensionTests: XCTestCase {
    
    // MARK: - toDouble
    
    func testToDouble_succeed() {
        let formatter = NumberFormatter()
        formatter.locale = .current
        XCTAssertEqual("111.123".toDouble(), 111.123)
        XCTAssertEqual((Locale.current.currencySymbol! + "111.123").toDouble(), 111.123)
        XCTAssertEqual((Locale.current.currencySymbol! + "11" + formatter.groupingSeparator! + "1.123").toDouble(), 111.123)
    }
    
    func testToDouble_fail() {
        let str = "%111.123"
        XCTAssertEqual(str.toDouble(), nil)
    }
    
    // MARK: - toDoubleString
    
    func testToDoubleString_succeed() {
        XCTAssertEqual("111.123".toDoubleString(), "111.12")
    }
    
    func testToDoubleString_fail() {
        XCTAssertEqual("%111.123".toDoubleString(), "")
    }
}
