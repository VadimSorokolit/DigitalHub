//
//  StorageProduct+copy.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 24.06.2025.
//
    
extension StorageProduct {
    
    func copy() -> StorageProduct {
        return StorageProduct(
            id: self.id,
            name: self.name,
            brandName: self.brandName,
            imageURL: self.imageURL,
            isFavorite: self.isFavorite,
            price: self.price,
            discount: self.discount,
            productState: self.state
        )
    }
    
}
