//
//  ProductViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

import Foundation
import Combine


class ProductViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var errorMessage: String? = nil
    
    private let apiClient: ProductApiClientProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: ProductApiClientProtocol) {
        self.apiClient = apiClient
        self.loadProducts()
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<APIError>) {
        if case let .failure(error) = completion {
            self.errorMessage = error.errorDescription
        }
    }
    
    func loadProducts() {
        self.apiClient.getProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)
    }
    
    func createProductWith(productName: String, brandName: String?, imageURL: String?, price: String?, discount: String?)  {
        self.apiClient.createProductWith(productName: productName, brandName: brandName, imageURL: imageURL, price: price, discount: discount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] product in
                self?.loadProducts()
            }
            .store(in: &cancellables)
    }
    
    func deleteProduct(id: String) {
        self.apiClient.deleteProductById(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] in
                self?.products.removeAll { $0.id == id }
            }
            .store(in: &cancellables)
    }
    
}

