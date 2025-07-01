//
//  StorageProduct+asModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 01.07.2025.
//
    
extension StorageProduct {
    
    var asModel: Product {
        Product(
            name: self.name,
            brandName: self.brandName,
            imageURL: self.imageURL,
            id: self.id,
            isFavorite: self.isFavorite,
            price: self.price,
            discount: self.discount
        )
    }
    
}

