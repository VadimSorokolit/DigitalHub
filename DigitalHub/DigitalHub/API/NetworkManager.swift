//
//  NetworkManager.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//

import Foundation
import Combine
import Moya
import CombineMoya
import Alamofire

// Client Interface
protocol ProductApiClientProtocol: AnyObject {
    func getProducts() -> AnyPublisher<[Product], APIError>
    func createProductWith(productName: String, isFavourite: Bool, brandName: String?, imageURL: String?, price: String?, discount: String?)  -> AnyPublisher<Product, APIError>
    func deleteProductById(_ id: String) -> AnyPublisher<Void, APIError>
}

class MoyaClient: ProductApiClientProtocol {

    private let provider = MoyaProvider<DigitalProductRouter>()
    
    // API: - https://docs.stripe.com/api/products/list
    
    func getProducts() -> AnyPublisher<[Product], APIError> {
        return self.provider
            .requestPublisher(.getProducts)
            .map { $0.data }
            .decode(type: ProductList.self, decoder: JSONDecoder())
            .map { $0.products }
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/create
    
    func createProductWith(productName: String, isFavourite: Bool = false, brandName: String?, imageURL: String?, price: String?, discount: String?) -> AnyPublisher<Product, APIError> {
        
        guard !productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: APIError.custom)
                .eraseToAnyPublisher()
        }
        return self.provider
            .requestPublisher(.createProductWith(productName: productName, isFavourite: isFavourite, brandName: brandName, imageURL: imageURL, price: price, discount: discount))
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    // API: - https://docs.stripe.com/api/products/delete
    
    func deleteProductById(_ id: String) -> AnyPublisher<Void, APIError> {
        return self.provider
            .requestPublisher(.deleteProductBy(id: id))
            .map { _ in
                return ()
            }
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
}





