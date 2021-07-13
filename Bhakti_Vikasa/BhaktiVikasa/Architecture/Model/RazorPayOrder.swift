//
//  RazorPayOrder.swift
//  Bhakti_Vikasa
//
//  Created by harishkumar on 15/02/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import Foundation
// MARK: - Welcome
struct RazorPayOrder: Codable {
    let id, entity: String
    let amount, amountPaid, amountDue: Int
    let currency, receipt: String
    let offerID: String?
    let status: String
    let attempts: Int
    let notes: [String]
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case id, entity, amount
        case amountPaid = "amount_paid"
        case amountDue = "amount_due"
        case currency, receipt
        case offerID = "offer_id"
        case status, attempts, notes
        case createdAt = "created_at"
    }
}



// MARK: - Welcome
struct RazorPayError_Ordar: Codable {
    let error: RazError
}

// MARK: - Error
 struct RazError: Codable {
    let code, errorDescription, source, step: String
    let reason: String
    let metadata: Metadata

    enum CodingKeys: String, CodingKey {
        case code
        case errorDescription = "description"
        case source, step, reason, metadata
    }
}

// MARK: - Metadata
struct Metadata: Codable {
}




