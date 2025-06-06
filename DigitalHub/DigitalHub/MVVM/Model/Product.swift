//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation

struct Product: Decodable, Identifiable {
    var name: String
    var brandName: String?
    var imageURL: String?
    let id: String
    var isFavorite: Bool
    var price: String?
    var discount: String?
    
    var isValid: Bool {
        !name.isEmpty
    }
    
    init() {
        self.name = ""
        self.id = UUID().uuidString
        self.isFavorite = false
    }
    
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


