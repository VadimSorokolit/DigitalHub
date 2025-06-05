//
//  ProductsViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//

import Foundation
import Combine

struct ProductsSection: Hashable, Equatable, Identifiable {
    let id: UUID = UUID()
    let type: SectionType
    let title: String
    let subtitle: String
    let buttonTitle: String
    let buttonImageName: String
    var products: [Product]
    
    enum SectionType: String {
        case favorite
        case unfavorite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductsSection, rhs: ProductsSection) -> Bool {
        lhs.id == rhs.id
    }
}

class ProductsViewModel: ObservableObject {
    
    // MARK: Objects
    
    private struct SectionConstants {
        struct Subtitles {
            static let favorite: String = "Check your favorite products"
            static let unfavorite: String = "Check your unfavorite products"
        }
        
        struct Button {
            static let title: String = "See All"
            static let imageName: String = "chevron.right"
        }
    }
    
    // MARK: - Properties. Public
    
    @Published var sections: [ProductsSection] = []
    @Published var searchResults: [Product] = []
    @Published var searchQuery: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isPagination: Bool = false
    
    // MARK: - Properties. Private
    
    private(set) var hasMoreData: Bool = false
    private let sectionConstants = SectionConstants()
    private var lastProductId: String?
    private let apiClient: ProductApiClientProtocol
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(apiClient: ProductApiClientProtocol) {
        self.apiClient = apiClient
        
        self.setupPublishers()
    }
    
    // MARK: - Methods. Private
    
    private func handleCompletion(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        self.isPagination = false
        
        if case let .failure(error) = completion {
            self.errorMessage = error.errorDescription
        }
    }
    
    private func setupPublishers() {
        $searchQuery
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchProducts(query: query)
            }
            .store(in: &subscriptions)
    }
    
    private func createSections(with products: [Product]) {
        let favoriteSection = ProductsSection(
            type: .favorite,
            title: ProductsSection.SectionType.favorite.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.favorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { $0.isFavorite }
        )
        
        let unfavoriteSection = ProductsSection(
            type: .unfavorite,
            title: ProductsSection.SectionType.unfavorite.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.unfavorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { !$0.isFavorite }
        )
        
        self.sections = [favoriteSection, unfavoriteSection]
    }
    
    private func addProducts(_ products: [Product]) {
        for product in products {
            self.addProduct(product)
        }
    }
    
    private func addProduct(_ product: Product) {
        let type: ProductsSection.SectionType = product.isFavorite ? .favorite : .unfavorite

        if let index = self.sections.firstIndex(where: { $0.type == type }) {
            self.sections[index].products.append(product)
        }
    }
    
    private func updateProduct(_ product: Product) {
        self.removeProduct(id: product.id)
        self.addProduct(product)
    }
    
    private func updateSearchResults(_ updatedProduct: Product) {
        if let index = self.searchResults.firstIndex(where: { $0.id == updatedProduct.id }) {
            self.searchResults[index] = updatedProduct
        }
    }
    
    private func removeProduct(id: String) {
        if let sectionIndex = self.sections.firstIndex(where: { section in
            section.products.contains(where: { $0.id == id })
        }) {
            self.sections[sectionIndex].products.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Methods. Public
    
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
        self.isPagination = true
        
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
    
    func searchProducts(query: String) {
        guard query.count > 2 else {
            self.searchResults.removeAll()
            return
        }
        self.isLoading = true
        
        self.apiClient.searchProducts(name: query, startingAfterId: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] productList in
                guard let self else { return }
                
                let products = productList.products
                self.searchResults = products
                
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
    
    func section(withId id: UUID) -> ProductsSection? {
        let section = self.sections.first { $0.id == id }
        return section
    }
    
    func updateSectionProductsStatus(sectionId: UUID) {
        if let section = self.section(withId: sectionId) {
            for product in section.products {
                self.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
            }
        }
    }
    
    func updateProductStatus(id: String, isFavourite: Bool)  {
        self.isLoading = true
        
        self.apiClient.updateProductStatus(id: id, isFavourite: isFavourite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] updatedProduct in
                self?.updateProduct(updatedProduct)
                self?.updateSearchResults(updatedProduct)
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


