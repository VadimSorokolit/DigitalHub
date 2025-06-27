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
    func searchProducts(name: String, startingAfterId: String?) -> AnyPublisher<ProductList, APIError>
    func createProduct(_ product: Product) -> AnyPublisher<Product, APIError>
    func createFile(_ data: Data) -> AnyPublisher<ImageFile, APIError>
    func createFileLink(_ fileId: String) -> AnyPublisher<ImageFileLink, APIError>
    func updateProductStatus(id: String, isFavorite: Bool) -> AnyPublisher<Product, APIError>
    func deleteProduct(id: String) -> AnyPublisher<String, APIError>
}

class MoyaClient: ProductApiClientProtocol {
    
    private let provider = MoyaProvider<DigitalProductRouter>()
    
    // API: - https://docs.stripe.com/api/products/search
    
    func searchProducts(name: String, startingAfterId: String? = nil) -> AnyPublisher<ProductList, APIError> {
        return provider
            .requestPublisher(.searchProducts(name: name, startingAfterId: startingAfterId))
            .map(\.data)
            .decode(type: ProductList.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/list
    
    func getProducts(startingAfterId: String? = nil) -> AnyPublisher<ProductList, APIError> {
        return provider
            .requestPublisher(.getProducts(startingAfterId: startingAfterId))
            .map(\.data)
            .decode(type: ProductList.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/files/create
    
    func createFile(_ data: Data) -> AnyPublisher<ImageFile, APIError> {
        return provider
            .requestPublisher(.createFile(data: data))
            .map(\.data)
            .decode(type: ImageFile.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }

    // API: - https://docs.stripe.com/api/file_links/create
    
    func createFileLink(_ fileId: String) -> AnyPublisher<ImageFileLink, APIError> {
        return provider
            .requestPublisher(.createFileLink(fileId))
            .map(\.data)
            .decode(type: ImageFileLink.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/create
    
    func createProduct(_ product: Product) -> AnyPublisher<Product, APIError> {
        if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
    
    func updateProductStatus(id: String, isFavorite: Bool) -> AnyPublisher<Product, APIError> {
        return self.provider
            .requestPublisher(.updateProductStatus(id: id, isFavorite: isFavorite))
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/delete
    
    func deleteProduct(id: String) -> AnyPublisher<String, APIError> {
        return self.provider
            .requestPublisher(.deleteProduct(id: id))
            .map{ $0.data }
            .decode(type: DeletionProductResponse.self, decoder: JSONDecoder())
            .tryMap { resp in
                guard resp.deleted else { throw APIError.deleteFailed }
                return resp.id
            }
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
}
