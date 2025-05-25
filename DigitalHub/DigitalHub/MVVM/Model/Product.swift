//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation

struct Product: Decodable, Identifiable {
    let name: String
    let brandName: String?
    let imageURL: String?
    let id: String
    let isFavorite: Bool
    let price: String?
    let discount: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case brandName = "description"
        case imageURL = "url"
        case id
        case isFavorite = "active"
        case price = "unit_label"
        case discount = "statement_descriptor"
    }
}

struct ProductList: Decodable {
    let products: [Product]
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case products = "data"
        case hasMore = "has_more"
    }
}


