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
    func createProdutWith(name: String, id: String) -> AnyPublisher<Product, APIError>
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
    
    func createProdutWith(name: String, id: String) -> AnyPublisher<Product, APIError> {
        return self.provider
            .requestPublisher(.createProductWith(name: name, id: id))
            .map { $0.data }
            .decode(type: Product.self, decoder: JSONDecoder())
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    //  API: - https://docs.stripe.com/api/products/delete
    
    func deleteProductById(_ id: String) -> AnyPublisher<Void, APIError> {
        return self.provider
            .requestPublisher(.deleteProductBY(id: id))
            .map { _ in
                return ()
            }
            .mapError { APIError.from($0) }
            .eraseToAnyPublisher()
    }
    
    public func Foo() {
        
    }
    
}





