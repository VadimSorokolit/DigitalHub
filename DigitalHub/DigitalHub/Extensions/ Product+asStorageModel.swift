//
//  Product+asStorageModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 02.07.2025.
//
    
extension Product {
    
    var asStorageModel: StorageProduct {
        let storageProduct = StorageProduct(
            id: self.id,
            name: self.name,
            brandName: self.brandName,
            imageURL: self.imageURL,
            isFavorite: self.isFavorite,
            price: self.price,
            discount: self.discount
        )
        return storageProduct
    }
    
}
