//
//  Product+asStorageModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 02.07.2025.
//
    
extension Product {
    
    var asStorageModel: StorageProduct {
        let cleanedDiscount = self.discount?
            .replacingOccurrences(of: "discount", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let storageProduct = StorageProduct(
            id: self.id,
            name: self.name,
            brandName: self.brandName,
            imageURL: self.imageURL,
            isFavorite: self.isFavorite,
            price: self.price,
            discount: cleanedDiscount
        )
        
        return storageProduct
    }
}
