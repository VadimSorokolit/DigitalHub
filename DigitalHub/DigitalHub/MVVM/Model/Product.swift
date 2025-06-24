//
//  Product.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation

struct Product: Codable, Identifiable {
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
    
    init(
        name: String,
        brandName: String? = nil,
        imageURL: String? = nil,
        id: String = UUID().uuidString,
        isFavorite: Bool = false,
        price: String? = nil,
        discount: String? = nil
    ) {
        self.name = name
        self.brandName = brandName
        self.imageURL = imageURL
        self.id = id
        self.isFavorite = isFavorite
        self.price = price
        self.discount = discount
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

struct DeletionProductResponse: Decodable {
    let id: String
    let deleted: Bool
}

struct ImageFile: Decodable {
    let id: String
    let fileName: String
    let purpose: String
    let size: Int
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fileName = "filename"
        case purpose
        case size
        case type
    }
}

struct ImageFileLink: Decodable {
    let id: String
    let file: String
    let url: String
}

