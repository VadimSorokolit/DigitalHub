//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

struct Price: Decodable {
    let id: String
    let unit_amount: Int
    let currency: String

    var formatted: String {
        let amount = Double(unit_amount) / 100
        return String(format: "%@ %.2f", currency.uppercased(), amount)
    }
}

struct Product: Decodable, Identifiable {
    let productName: String
    let brandName: String?
    let imageURL: String?
    let id: String
    let isFavourite: Bool
    let defaultPrice: Price?
    let discount: String?

    enum CodingKeys: String, CodingKey {
        case productName = "name"
        case brandName = "description"
        case imageURL = "url"
        case id
        case isFavourite = "livemode"
        case defaultPrice = "default_price"
        case discount = "tax_code"
    }
}

struct ProductList: Decodable {
    let products: [Product]

    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
}


