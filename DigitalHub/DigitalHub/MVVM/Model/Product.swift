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
    let price: Price?
    let discount: String?
    
    struct Price: Decodable {
        let id: String
        let unitAmount: Int
        let currency: String
        
        var formatted: String {
            let amount = Double(unitAmount) / 100
            return String(format: "%@ %.2f", currency.uppercased(), amount)
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case unitAmount = "unit_amount"
            case currency
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case productName = "name"
        case brandName = "description"
        case imageURL = "url"
        case id
        case isFavourite = "livemode"
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


