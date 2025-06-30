//
//  StorageProduct.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import Foundation
import SwiftData

enum ProductState: String {
    case synced
    case created
    case updated
    case deleted
}

@Model
final class StorageProduct {
    
    // MARK: - Product Properties
    @Attribute(.unique) var id: String
    
    var name: String
    var brandName: String?
    var imageURL: String?
    var isFavorite: Bool
    var price: String?
    var discount: String?
    
    var state: String = ProductState.created.rawValue
    
    var isValid: Bool {
        guard !name.isEmpty, let brand = brandName, !brand.isEmpty else {
            return false
        }
        let rawPrice = price?.filter { $0.isNumber } ?? ""
        guard let priceValue = Int(rawPrice), (1...9999).contains(priceValue) else {
            return false
        }
        let rawDiscount = discount?.filter { $0.isNumber } ?? ""
        guard let discountValue = Int(rawDiscount), (1...99).contains(discountValue) else {
            return false
        }
        return true
    }
    
    // MARK: - Initializers
    
    init(
        id: String,
        name: String,
        brandName: String? = nil,
        imageURL: String? = nil,
        isFavorite: Bool = false,
        price: String? = nil,
        discount: String? = nil,
        productState: String = ProductState.created.rawValue
    ) {
        self.id = id
        self.name = name
        self.brandName = brandName
        self.imageURL = imageURL
        self.isFavorite = isFavorite
        self.price = price
        self.discount = discount
        self.state = productState
    }
    
    convenience init(emptyWith id: String = "prod_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))") {
        self.init(
            id: id,
            name: "",
            brandName: nil,
            imageURL: nil,
            isFavorite: false,
            price: nil,
            discount: nil,
            productState: ProductState.created.rawValue
        )
    }
    
    // MARK: - Methods
    
    func copy(withState newState: ProductState) -> StorageProduct {
        return StorageProduct(
            id: self.id,
            name: self.name,
            brandName: self.brandName,
            imageURL: self.imageURL,
            isFavorite: self.isFavorite,
            price: self.price,
            discount: self.discount,
            productState: newState.rawValue
        )
    }
    
}
