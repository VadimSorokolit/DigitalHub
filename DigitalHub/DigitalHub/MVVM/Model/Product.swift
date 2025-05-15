//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    
struct Product: Decodable, Identifiable {
    let productName: String
    let brandName: String?
    let imageURL: String?
    let id: String
    let isFavourite: Bool
    let price: String?
    let discount: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "name"
        case brandName = "description"
        case imageURL = "url"
        case id
        case isFavourite = "active"
        case price = "unit_label"
        case discount = "statement_descriptor"
    }
}

struct ProductList: Decodable {
    let products: [Product]

    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
}


