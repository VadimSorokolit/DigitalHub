//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

struct Product: Decodable, Identifiable {
    let name: String
    let id: String
}

struct ProductList: Decodable {
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
}
