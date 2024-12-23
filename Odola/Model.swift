//
//  Model.swift
//  Odola
//
//  Created by Jian Ma on 12/22/24.
//
import Foundation
// MARK: - Models
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// Mock transaction data
struct Transaction: Codable {
    let id: String
    let status: String
    let bestRates: [String]?
}
