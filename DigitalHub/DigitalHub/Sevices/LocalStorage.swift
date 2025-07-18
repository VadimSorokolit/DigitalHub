//
//  LocalStorage.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 17.06.2025.
//

import Foundation
import Combine
import SwiftData

protocol ProductStorageProtocol: AnyObject {
    func fetchAllProducts() -> AnyPublisher<[StorageProduct], APIError>
    func searchProducts(query: String) -> AnyPublisher<[StorageProduct], APIError>
    func createProduct(_ product: StorageProduct) -> AnyPublisher<StorageProduct, APIError>
    func updateProduct(ids: [String], newState: ProductState, isFavorite: Bool?) -> AnyPublisher<[StorageProduct], APIError>
    func deleteProduct(id: String) -> AnyPublisher<String, APIError>
}

class LocalStorage: ProductStorageProtocol {
    
    // MARK: - Properties
    
    private let context: ModelContext
    
    // MARK: - Initializer
    
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Methods
    
    func fetchAllProducts() -> AnyPublisher<[StorageProduct], APIError> {
        let result: Result<[StorageProduct], APIError>

        do {
            let products = try self.context.fetch(FetchDescriptor<StorageProduct>())
            result = .success(products)
        } catch {
            self.context.rollback()
            result = .failure(.storage(error))
        }

        return result
            .publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchProducts(query: String) -> AnyPublisher<[StorageProduct], APIError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.unknown))
                return
            }
            
            do {
                let descriptor = FetchDescriptor<StorageProduct>(
                    predicate: #Predicate { $0.name.localizedStandardContains(query) }
                )
                let results = try self.context.fetch(descriptor)
                promise(.success(results))
                return
            } catch {
                promise(.failure(.storage(error)))
                return
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createProduct(_ product: StorageProduct) -> AnyPublisher<StorageProduct, APIError> {
        Future { promise in
            if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                promise(.failure(APIError.emptyProductName))
                return
            }
            product.state = ProductState.created.rawValue
            
            self.context.insert(product)
            
            do {
                try self.context.save()
                promise(.success(product))
            } catch {
                self.context.rollback()
                promise(.failure(APIError.createProductFailed))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func updateProduct(ids: [String], newState: ProductState, isFavorite: Bool?) -> AnyPublisher<[StorageProduct], APIError> {
        Future { [weak self] promise in
            DispatchQueue.main.async {
                guard let self else {
                    promise(.failure(APIError.unknown))
                    return
                }
                
                do {
                    let descriptor = FetchDescriptor<StorageProduct>(predicate: #Predicate { ids.contains($0.id) })
                    let products = try self.context.fetch(descriptor)
                    
                    if products.isEmpty {
                        promise(.failure(.notFound))
                        return
                    }
                    for product in products {
                        if let isFavorite = isFavorite {
                            product.isFavorite = isFavorite
                        }
                        product.state = newState.rawValue
                    }
                    
                    try self.context.save()
                    promise(.success(products))
                    return
                    
                } catch {
                    self.context.rollback()
                    promise(.failure(APIError.storage(error)))
                    return
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteProduct(id: String) -> AnyPublisher<String, APIError> {
        Future { [weak self] promise in
            DispatchQueue.main.async {
                guard let self else {
                    promise(.failure(APIError.unknown))
                    return
                }
                
                do {
                    let descriptor = FetchDescriptor<StorageProduct>(predicate: #Predicate { $0.id == id })
                    let results = try self.context.fetch(descriptor)
                    guard let product = results.first else {
                        promise(.failure(.notFound))
                        return
                    }
                    
                    self.context.delete(product)
                    try self.context.save()
                    promise(.success(product.id))
                    return
                } catch {
                    self.context.rollback()
                    promise(.failure(APIError.storage(error)))
                    return
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
}

extension ProductStorageProtocol {
    
    func update(ids: [String], newState: ProductState) -> AnyPublisher<[StorageProduct], APIError> {
        self.updateProduct(ids: ids, newState: newState, isFavorite: nil)
    }
    
}
