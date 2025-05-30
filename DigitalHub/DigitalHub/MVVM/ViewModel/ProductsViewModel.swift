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
    
    // MARK: - Properties
    
    @Published var sections: [ProductsSection] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private(set) var hasMoreData: Bool = false
    private let sectionConstants = SectionConstants()
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
    
    func updateSectionProductsStatus(sectionId: UUID) {
        if let section = self.section(withId: sectionId) {
            for product in section.products {
                self.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
            }
        }
    }
    
    private func removeProduct(id: String) {
        if let sectionIndex = self.sections.firstIndex(where: { section in
            section.products.contains(where: { $0.id == id })
        }) {
            self.sections[sectionIndex].products.removeAll { $0.id == id }
        }
    }
    
    func section(withId id: UUID) -> ProductsSection? {
        let section = self.sections.first { $0.id == id }
        return section
    }
    
    // MARK: - For test
    
    func getMockData() {
        var products: [Product] = []
        
        for i in 1...10 {
            let unfavoriteProduct = Product(name: "iPhoneXS", brandName: "Apple(\(i))", imageURL: "mockImage", id: "", isFavorite: false, price: "100", discount: "20")
            let favoriteProduct = Product(name: "iPhone16ProMax iPhone16ProMax iPhone16ProMax", brandName: "iPhone16ProMax iPhone16ProMax Apple Apple Apple Apple Apple(\(i))", imageURL: "mockImage", id: "", isFavorite: true, price: "100", discount: "30")
            products.append(unfavoriteProduct)
            products.append(favoriteProduct)
        }
        self.createSections(with: products)
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


