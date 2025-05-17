//
//  ProductsViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject {
    
    // MARK: - Objects
    
    private struct Constants {
        static let favouriteSubtitle: String = "Check your Favorite Products list"
        static let unfavouriteSubtitle: String = "Check your common products"
        static let buttonTitle: String = "See All"
        static let buttonImageName: String = "chevron.right"
    }
    
    struct Section: Identifiable {
        let id: UUID = UUID()
        let type: SectionType
        let title: String
        let subtitle: String
        let buttonTitle: String
        let buttonImageName: String
        var items: [Product]
        
        enum SectionType: String {
            case favorite
            case unfavorite
        }
    }
    
    // MARK: - Properties
    
    @Published var products: [Product] = []
    @Published var sections: [Section] = []
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private var lastProductId: String?
    private let apiClient: ProductApiClientProtocol
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(apiClient: ProductApiClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Methods
    
    private func handleCompletion(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        if case let .failure(error) = completion {
            self.errorMessage = error.errorDescription
        }
    }
    
    private func createSections(with products: [Product]) {
        let favoriteSection = Section(
            type: .favorite,
            title: Section.SectionType.favorite.rawValue.capitalized,
            subtitle: Constants.favouriteSubtitle,
            buttonTitle: Constants.buttonTitle,
            buttonImageName: Constants.buttonImageName,
            items: products.filter { $0.isFavorite }
        )
        
        let unfavoriteSection = Section(
            type: .unfavorite,
            title: Section.SectionType.unfavorite.rawValue.capitalized,
            subtitle: Constants.unfavouriteSubtitle,
            buttonTitle: Constants.buttonTitle,
            buttonImageName: Constants.buttonImageName,
            items: products.filter { !$0.isFavorite }
        )
        
        self.sections = [favoriteSection, unfavoriteSection]
    }
    
    private func addProduct(_ product: Product) {
        if let oldIndex = self.sections.firstIndex(where: { $0.items.contains(where: { $0.id == product.id }) }) {
            var updatedSection = self.sections[oldIndex]
            updatedSection.items.removeAll { $0.id == product.id }
            self.sections[oldIndex] = updatedSection
        }
        
        if product.isFavorite {
            if let index = self.sections.firstIndex(where: { $0.type == .favorite }) {
                var updatedSection = self.sections[index]
                updatedSection.items.append(product)
                self.sections[index] = updatedSection
            }
        } else {
            if let index = self.sections.firstIndex(where: { $0.type == .unfavorite }) {
                var updatedSection = self.sections[index]
                updatedSection.items.append(product)
                self.sections[index] = updatedSection
            }
        }
    }
    
    private func removeProductFromSections(id: String) {
        for index in self.sections.indices {
            var updatedSection = self.sections[index]
            updatedSection.items.removeAll { $0.id == id }
            self.sections[index] = updatedSection
        }
    }
    
    func loadProducts() {
        self.isLoading = true
        self.apiClient.getProducts(startingAfter: lastProductId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] productList in
                let newProducts = productList.products

                self?.sections = []
                self?.createSections(with: newProducts)

                self?.lastProductId = newProducts.last?.id

                if productList.hasMore {
                    self?.loadProducts()
                }
            }
            .store(in: &subscriptions)
    }
    
    func createProduct(productName: String, isFavorite: Bool, brandName: String?, imageURL: String?, price: String?, discount: String?) {
        self.isLoading = true
        
        let newProduct: Product = Product(
            productName: productName,
            brandName: brandName,
            imageURL: imageURL,
            id: UUID().uuidString,
            isFavorite: isFavorite,
            price: price,
            discount: discount
        )
        
        self.apiClient.create(product: newProduct)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] product in
                self?.addProduct(product)
            }
            .store(in: &subscriptions)
    }
    
    func updateProductStatus(id: String, isFavourite: Bool)  {
        self.isLoading = true
        self.apiClient.updateProductStatus(id: id, isFavourite: isFavourite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] updatedProduct in
                self?.addProduct(updatedProduct)
            }
            .store(in: &subscriptions)
    }
    
    func deleteProduct(id: String) {
        self.isLoading = true
        self.apiClient.deleteProduct(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] in
                self?.removeProductFromSections(id: id)
            }
            .store(in: &subscriptions)
    }
    
}
