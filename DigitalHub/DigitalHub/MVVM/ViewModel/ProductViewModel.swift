//
//  ProductViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

enum SectionType: String {
    case favourite
    case unFavourite
}

struct Section: Identifiable {
    let id: UUID = UUID()
    let type: SectionType
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonImage: String
    var items: [Product]
}

import Foundation
import Combine

class ProductViewModel: ObservableObject {
    
    // MARK: - Objects
    
    struct Constants {
        static let favouriteSubtitle: String = "Check your Favorite Products list"
        static let unfavouriteSubtitle: String = "Check your common products"
        static let buttonTitle: String = "See All"
        static let buttonImageName = "chevron.right"
    }
    
    // MARK: - Properties
    
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var sections: [Section] = []
    @Published var errorMessage: String? = nil
    
    private let apiClient: ProductApiClientProtocol
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(apiClient: ProductApiClientProtocol) {
        self.apiClient = apiClient
        self.loadProducts()
    }
    
    // MARK: - Methods
    
    private func handleCompletion(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        if case let .failure(error) = completion {
            self.errorMessage = error.errorDescription
        }
    }
    
    private func updateSections() {
        let favouriteSection = Section(
            type: .favourite,
            title: SectionType.favourite.rawValue.capitalized,
            subtitle: Constants.favouriteSubtitle,
            buttonTitle: Constants.buttonTitle,
            buttonImage: Constants.buttonImageName,
            items: products.filter { $0.isFavourite }
        )

        let unfavouriteSection = Section(
            type: .unFavourite,
            title: SectionType.unFavourite.rawValue.capitalized,
            subtitle: Constants.unfavouriteSubtitle,
            buttonTitle: Constants.buttonTitle,
            buttonImage: Constants.buttonImageName,
            items: products.filter { !$0.isFavourite }
        )

        self.sections = [favouriteSection, unfavouriteSection]
    }
    
    func loadProducts() {
        self.isLoading = true
        self.apiClient.getProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.products = products
                self?.updateSections()
            }
            .store(in: &cancellables)
    }
    
    func createProductWith(productName: String, isFavourite: Bool, brandName: String?, imageURL: String?, price: String?, discount: String?)  {
        self.isLoading = true
        self.apiClient.createProductWith(productName: productName, isFavourite: isFavourite, brandName: brandName, imageURL: imageURL, price: price, discount: discount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] product in
                self?.loadProducts()
            }
            .store(in: &cancellables)
    }
    
    func updateProductStatusBy(id: String, isFavourite: Bool)  {
        self.isLoading = true
        self.apiClient.updateProductStatusBy(id, isFavourite: isFavourite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] updateProduct in
                self?.loadProducts()
            }
            .store(in: &cancellables)
    }
    
    func deleteProductBy(id: String) {
        self.isLoading = true
        self.apiClient.deleteProductById(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] in
                self?.loadProducts()
            }
            .store(in: &cancellables)
    }
    
}

