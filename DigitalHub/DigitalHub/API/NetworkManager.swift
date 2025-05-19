//  NetworkManager.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//

import Foundation
import Combine
import Moya
import CombineMoya

// Client Interface
protocol ProductApiClientProtocol: AnyObject {
    func getProducts(startingAfterId: String?) -> AnyPublisher<ProductList, APIError>
    func createProduct(_ product: Product) -> AnyPublisher<Product, APIError>
    func updateProductStatus(id: String, isFavourite: Bool) -> AnyPublisher<Product, APIError>
    func deleteProduct(id: String) -> AnyPublisher<Void, APIError>
}

class MoyaClient: ProductApiClientProtocol {

    private let provider = MoyaProvider<DigitalProductRouter>()
    
    // API: - https://docs.stripe.com/api/products/search 
    
    // API: - https://docs.stripe.com/api/products/list
    
    func getProducts(startingAfterId: String? = nil) -> AnyPublisher<ProductList, APIError> {
        return provider
            .requestPublisher(.getProducts(startingAfterId: startingAfterId))
            .map(\.data)
            .decode(type: ProductList.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/create
    
    func createProduct(_ product: Product) -> AnyPublisher<Product, APIError> {
        if product.productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Fail(error: APIError.emptyProductName)
                .eraseToAnyPublisher()
        }
        return self.provider
            .requestPublisher(.createProduct(product: product))
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/update
    
    func updateProductStatus(id: String, isFavourite: Bool) -> AnyPublisher<Product, APIError> {
        return self.provider
            .requestPublisher(.updateProductStatus(id: id, isFavourite: isFavourite))
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/delete
    
    func deleteProduct(id: String) -> AnyPublisher<Void, APIError> {
        return self.provider
            .requestPublisher(.deleteProduct(id: id))
            .map { _ in
                return ()
            }
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
}
