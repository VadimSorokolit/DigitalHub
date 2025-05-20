//
//  ProductsViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation
import Combine

class ProductsViewModel: ObservableObject {
    
    // MARK: Objects
    
    struct SectionConstants {
        struct Subtitles {
            static let favorite: String = "Check your Favorite Products list"
            static let unfavorite: String = "Check your common products"
        }
        
        struct Button {
            static let title: String = "See All"
            static let imageName: String = "chevron.right"
        }
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
    
    @Published var sections: [Section] = []
    @Published var hasMoreData: Bool = false
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    let sectionConstants = SectionConstants()
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
            subtitle: SectionConstants.Subtitles.favorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            items: products.filter { $0.isFavorite }
        )
        
        let unfavoriteSection = Section(
            type: .unfavorite,
            title: Section.SectionType.unfavorite.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.unfavorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            items: products.filter { !$0.isFavorite }
        )
        
        self.sections = [favoriteSection, unfavoriteSection]
    }
    
    private func addProducts(_ products: [Product]) {
        for product in products {
            self.addProduct(product)
        }
    }
    
    private func addProduct(_ product: Product) {
        let type: Section.SectionType = product.isFavorite ? .favorite : .unfavorite

        if let index = sections.firstIndex(where: { $0.type == type }) {
            sections[index].items.append(product)
        }
    }
    
    private func updateProduct(_ product: Product) {
        self.removeProduct(id: product.id)
        self.addProduct(product)
    }
    
    private func removeProduct(id: String) {
        if let sectionIndex = self.sections.firstIndex(where: { section in
            section.items.contains(where: { $0.id == id })
        }) {
            self.sections[sectionIndex].items.removeAll { $0.id == id }
        }
    }
    
    func loadFirstPage() {
        self.isLoading = true
        
        self.apiClient.getProducts(startingAfterId: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] productList in
                guard let self else { return }
                
                let products = productList.products
                self.createSections(with: products)
                
                self.lastProductId = products.last?.id
                
                if self.hasMoreData != productList.hasMore {
                    self.hasMoreData = productList.hasMore
                }
            }
            .store(in: &self.subscriptions)
    }
    
    func loadNextPage() {
        self.isLoading = true
        
        self.apiClient.getProducts(startingAfterId: self.lastProductId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] productList in
                guard let self else { return }

                let products = productList.products
                self.addProducts(products)
                
                self.lastProductId = products.last?.id
                
                if self.hasMoreData != productList.hasMore {
                    self.hasMoreData = productList.hasMore
                }
            }
            .store(in: &self.subscriptions)
    }
    
    func createProduct(_ newProduct: Product) {
        self.isLoading = true
        
        self.apiClient.createProduct(newProduct)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] product in
                self?.addProduct(product)
            }
            .store(in: &self.subscriptions)
    }
    
    func updateProductStatus(id: String, isFavourite: Bool)  {
        self.isLoading = true
        self.apiClient.updateProductStatus(id: id, isFavourite: isFavourite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] updatedProduct in
                self?.updateProduct(updatedProduct)
            }
            .store(in: &self.subscriptions)
    }
    
    func deleteProduct(id: String) {
        self.isLoading = true
        self.apiClient.deleteProduct(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] in
                self?.removeProduct(id: id)
            }
            .store(in: &self.subscriptions)
    }
    
}


