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
    var products: [StorageProduct]
    
    enum SectionType: String {
        case favorites
        case unfavorites
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
    @Published var searchResults: [StorageProduct] = []
    @Published var searchQuery: String = ""
    @Published var errorMessage: String? = nil
    @Published var isStorageSaveInProgress: Bool = false
    @Published var isLoading: Bool = false
    @Published var isPagination: Bool = false
    @Published var fileLinkURL: String? = nil
    
    // MARK: - Properties. Private
    
    private(set) var hasMoreData: Bool = false
    private let sectionConstants: ProductsViewModel.SectionConstants = SectionConstants()
    private var lastProductId: String?
    private let apiClient: ProductApiClientProtocol
    private let dataStorage: ProductStorageProtocol
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    private let MAX_PUBLISHERS_PER_REQUEST: Int = 25
    private let DELAY_BETWEEN_REQUESTS: TimeInterval = 1.0
    
    // MARK: - Initializer
    
    init(dataStorage: ProductStorageProtocol, apiClient: ProductApiClientProtocol) {
        self.apiClient = apiClient
        self.dataStorage = dataStorage
        
        self.setupPublishers()
    }
    
    // MARK: - Methods. Private
    
    private func handleCompletion(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        self.isPagination = false
        self.isStorageSaveInProgress = false
        
        if case let .failure(error) = completion {
            self.errorMessage = error.errorDescription
        }
    }
    
    private func setupPublishers() {
        self.$searchQuery
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchProducts(query: query)
            }
            .store(in: &self.subscriptions)
        
        NetworkMonitor.shared.$isConnected
            .prepend(NetworkMonitor.shared.isConnected)
            .removeDuplicates()
            .sink { isConnected in
                if isConnected {
                    self.syncAllPendingProducts()
                }
            }
            .store(in: &self.subscriptions)
    }
    
    private func convert(_ storage: StorageProduct) -> Product {
        Product(
            name: storage.name,
            brandName: storage.brandName,
            imageURL: storage.imageURL,
            id: storage.id,
            isFavorite: storage.isFavorite,
            price: storage.price,
            discount: storage.discount
        )
    }
    
    private func createSections(with products: [StorageProduct]) {
        let favoriteSection = ProductsSection(
            type: .favorites,
            title: ProductsSection.SectionType.favorites.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.favorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { $0.isFavorite && $0.state != ProductState.deleted.rawValue && $0.state != ProductState.deletedOffline.rawValue }
        )
        
        let unfavoriteSection = ProductsSection(
            type: .unfavorites,
            title: ProductsSection.SectionType.unfavorites.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.unfavorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { !$0.isFavorite && $0.state != ProductState.deleted.rawValue && $0.state != ProductState.deletedOffline.rawValue }
        )
        
        self.sections = [favoriteSection, unfavoriteSection]
    }
    
    private func createProducts(_ newProducts: [Product]) {
        self.isLoading = true
        
        Publishers.Sequence(sequence: newProducts)
            .flatMap(maxPublishers: .max(self.MAX_PUBLISHERS_PER_REQUEST)) { product in
                self.apiClient.createProduct(product)
                    .delay(for: .seconds(self.DELAY_BETWEEN_REQUESTS), scheduler: DispatchQueue.global())
                    .flatMap { [weak self] createdProduct -> AnyPublisher<[StorageProduct], Never> in
                        guard let self else { return Empty().eraseToAnyPublisher() }
                        
                        return self.dataStorage.update(ids: [createdProduct.id], newState: .synced)
                            .handleEvents(receiveOutput: { _ in })
                            .catch { error in
                                Empty().eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    private func addSectionProduct(_ product: StorageProduct) {
        let type: ProductsSection.SectionType = product.isFavorite ? .favorites : .unfavorites
        
        if let index = self.sections.firstIndex(where: { $0.type == type }) {
            self.sections[index].products.append(product)
        }
    }
    
    private func updateSectionProduct(_ product: StorageProduct) {
        self.removeSectionProduct(id: product.id)
        
        guard product.state != ProductState.deleted.rawValue,
              product.state != ProductState.deletedOffline.rawValue else { return }
        
        self.addSectionProduct(product)
    }
    
    private func updateProductsStatus(_ products: [Product]) {
        self.isLoading = true
        
        Publishers.Sequence(sequence: products)
            .flatMap(maxPublishers: .max(self.MAX_PUBLISHERS_PER_REQUEST)) { product in
                self.apiClient.updateProductStatus(id: product.id, isFavorite: product.isFavorite)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .seconds(self.DELAY_BETWEEN_REQUESTS), scheduler: DispatchQueue.global())
                    .flatMap { [weak self] updateProduct -> AnyPublisher<[StorageProduct], Never> in
                        guard let self else { return Empty().eraseToAnyPublisher() }
                        
                        return self.dataStorage.update(ids: [updateProduct.id], newState: .synced)
                            .handleEvents(receiveOutput: { updated in
                            })
                            .catch { error in
                                Empty().eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    private func updateSearchResult(_ storageProduct: StorageProduct) {
        guard let index = self.searchResults.firstIndex(where: { $0.id == storageProduct.id }) else { return }
        self.searchResults[index] = storageProduct
    }
    
    private func removeSectionProduct(id: String) {
        if let sectionIndex = self.sections.firstIndex(where: { section in
            section.products.contains(where: { $0.id == id })
        }) {
            self.sections[sectionIndex].products.removeAll { $0.id == id }
        }
    }
    
    private func deleteProducts(_ products: [Product]) {
        self.isLoading = true
        
        Publishers.Sequence(sequence: products)
            .flatMap(maxPublishers: .max(self.MAX_PUBLISHERS_PER_REQUEST)) { product in
                self.apiClient.deleteProduct(id: product.id)
                    .delay(for: .seconds(self.DELAY_BETWEEN_REQUESTS), scheduler: DispatchQueue.global())
                    .flatMap { [weak self] productId in
                        guard let self = self else {
                            return Fail<String, APIError>(error: .deleteFailed)
                                .eraseToAnyPublisher()
                        }
                        return self.dataStorage
                            .deleteProduct(id: productId)
                            .handleEvents(receiveOutput: { id in
                                self.removeSectionProduct(id: id)
                            })
                            .eraseToAnyPublisher()
                    }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in
            }
            .store(in: &self.subscriptions)
    }
    
    private func deleteOfflineProducts(_ products: [Product]) {
        self.isLoading = true
        
        let publishers = products.map { product in
            self.dataStorage.deleteProduct(id: product.id)
                .handleEvents(receiveOutput: { [weak self] id in
                    self?.removeSectionProduct(id: id)
                })
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    // MARK: - Methods. Public
    
    func loadStorageProducts() {
        self.isLoading = true
        
        self.dataStorage.fetchAllProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { products in
                self.dataStorage.setProducts(products)
                self.createSections(with: products)
            }
            .store(in: &self.subscriptions)
    }
    
    func createStorageProduct(_ product: StorageProduct) {
        self.isStorageSaveInProgress = true
        
        self.dataStorage.createProduct(product)
            .handleEvents(receiveOutput: { created in
                self.addSectionProduct(created)
            })
            .flatMap { [weak self] _ in
                self?.dataStorage.fetchAllProducts()
                ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.dataStorage.setProducts(products)
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &self.subscriptions)
    }
    
    func updateStorageProductStatus(_ product: StorageProduct, newState: ProductState) {
        self.isStorageSaveInProgress = true
        
        let isOffline = !NetworkMonitor.shared.isConnected
        
        let finalState: ProductState = {
            if product.state == ProductState.created.rawValue, isOffline, newState != .deleted {
                return ProductState(rawValue: product.state) ?? .created
            } else if product.state == ProductState.created.rawValue, isOffline, newState == .deleted {
                return ProductState.deletedOffline
            }
            else {
                return newState
            }
        }()
        
        self.dataStorage.updateProduct(ids: [product.id], newState: finalState, isFavorite: product.isFavorite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.updateSectionProduct(product)
                self?.updateSearchResult(product)
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &self.subscriptions)
    }
    
    func updateProductsStatus(sectionId: UUID) {
        guard let section = section(withId: sectionId), !section.products.isEmpty else { return }
        
        let isFavorite = section.products.first?.isFavorite
        
        let createdIDs = section.products
            .filter { $0.state == ProductState.created.rawValue }
            .map { $0.id }
        
        let updatedIDs = section.products
            .filter { $0.state != ProductState.created.rawValue }
            .map { $0.id }
        
        var publishers: [AnyPublisher<[StorageProduct], APIError>] = []
        
        if !createdIDs.isEmpty {
            let createdPublisher = self.dataStorage.updateProduct(ids: createdIDs, newState: .created, isFavorite: isFavorite)
            publishers.append(createdPublisher)
        }
        
        if !updatedIDs.isEmpty {
            let updatedPublisher = self.dataStorage.updateProduct(ids: updatedIDs, newState: .updated, isFavorite: isFavorite)
            publishers.append(updatedPublisher)
        }
        
        if publishers.isEmpty { return }
        
        Publishers.MergeMany(publishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                products.forEach { self?.updateSectionProduct($0) }
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &self.subscriptions)
    }
    
    private func syncAllPendingProducts() {
        self.dataStorage.fetchAllProducts()
            .sink(receiveCompletion: { completion in
                self.handleCompletion(completion)
            }, receiveValue: { [weak self] products in
                self?.syncPending(from: products)
            })
            .store(in: &self.subscriptions)
    }
    
    private func syncPending(from products: [StorageProduct]) {
        let created = products.filter { $0.state == ProductState.created.rawValue }.map { self.convert($0) }
        let updated = products.filter { $0.state == ProductState.updated.rawValue }.map { self.convert($0) }
        let deleted = products.filter { $0.state == ProductState.deleted.rawValue }.map { self.convert($0) }
        let deletedOffline = products.filter { $0.state == ProductState.deletedOffline.rawValue }.map { self.convert($0) }
        
        if !created.isEmpty {
            self.createProducts(created)
        }
        if !updated.isEmpty {
            self.updateProductsStatus(updated)
        }
        if !deleted.isEmpty {
            self.deleteProducts(deleted)
        }
        if !deletedOffline.isEmpty {
            self.deleteOfflineProducts(deletedOffline)
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
                // self.createSections(with: products)
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
                // self.addProducts(products)
                
                self.lastProductId = products.last?.id
                
                if self.hasMoreData != productList.hasMore {
                    self.hasMoreData = productList.hasMore
                }
            }
            .store(in: &self.subscriptions)
    }
    
    private func searchProducts(query: String) {
        guard query.count > 2 else {
            self.searchResults.removeAll()
            return
        }
        self.isLoading = true
        
        self.dataStorage.searchProducts(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &self.subscriptions)
    }
    
    func createFile(_ file: Data) {
        self.isLoading = true
        
        self.apiClient.createFile(file)
            .flatMap { [weak self] file in
                self?.apiClient.createFileLink(file.id)
                ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] fileLink in
                self?.fileLinkURL = fileLink.url
            }
            .store(in: &self.subscriptions)
    }
    
    func section(withId id: UUID) -> ProductsSection? {
        let section = self.sections.first { $0.id == id }
        return section
    }
    
}
