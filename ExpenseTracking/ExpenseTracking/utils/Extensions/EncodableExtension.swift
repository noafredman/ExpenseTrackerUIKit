//
//  EncodableExtension.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

extension Encodable {
    func encode(using encoder: JSONEncoder = JSONEncoder()) throws -> Data { try encoder.encode(self) }
}
