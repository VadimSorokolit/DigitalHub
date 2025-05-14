//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

struct Product: Decodable, Identifiable {
    let name: String
    let brand: String?
    let imageURL: String?
    let id: String
    let isFavourite: Bool
    let price: String?
    let discount: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case brand = "description"
        case id
        case imageURL = "url"
        case isFavourite = "liveMode"
        case price = "default_price"
        case discount = "tax_code"
    }
}

struct ProductList: Decodable {
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
}


