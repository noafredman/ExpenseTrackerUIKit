//
//  UserInfo.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import Foundation

struct UserInfo: Codable, Equatable {
    let id: UUID
    let name: String
    var expenseCluster: [ExpenseCluster] = [ExpenseCluster]()
}

struct ExpenseCluster: Codable, Equatable {
    let id: UUID
    let date: Date
    var expenses: [Expense]
    
    func totalAmount() -> Double {
        expenses.reduce(0) {
            $0 + $1.amount
        }
    }
    
    init(id: UUID, date: Date, expenses: [Expense]) {
        self.id = id
        self.date = date
        self.expenses = expenses
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.expenses = try container.decode([Expense].self, forKey: .expenses)
    }
}

struct Expense: Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    
    init(id: UUID, title: String, amount: Double) {
        self.id = id
        self.title = title
        self.amount = amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.amount = try container.decode(Double.self, forKey: .amount)
    }
}
