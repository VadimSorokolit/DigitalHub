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
    @Published var searchResults: [StorageProduct] = []
    @Published var storageProducts: [StorageProduct] = []
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
    private let dataStorage: ProductApiStorageProtocol
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(dataStorage: ProductApiStorageProtocol, apiClient: ProductApiClientProtocol) {
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
        $searchQuery
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchProducts(query: query)
            }
            .store(in: &subscriptions)
        
        NetworkMonitor.shared.$isConnected
            .prepend(NetworkMonitor.shared.isConnected)
            .removeDuplicates()
            .sink { isConnected in
                if isConnected {
                    self.syncAllPendingProducts()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func createSections(with products: [StorageProduct]) {
        let favoriteSection = ProductsSection(
            type: .favorite,
            title: ProductsSection.SectionType.favorite.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.favorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { $0.isFavorite && $0.state != ProductState.deleted.rawValue && $0.state != ProductState.deletedOffline.rawValue }
        )
        
        let unfavoriteSection = ProductsSection(
            type: .unfavorite,
            title: ProductsSection.SectionType.unfavorite.rawValue.capitalized,
            subtitle: SectionConstants.Subtitles.unfavorite,
            buttonTitle: SectionConstants.Button.title,
            buttonImageName: SectionConstants.Button.imageName,
            products: products.filter { !$0.isFavorite && $0.state != ProductState.deleted.rawValue && $0.state != ProductState.deletedOffline.rawValue }
        )
        
        self.sections = [favoriteSection, unfavoriteSection]
    }
    
    private func addProduct(_ product: StorageProduct) {
        let type: ProductsSection.SectionType = product.isFavorite ? .favorite : .unfavorite
        
        if let index = self.sections.firstIndex(where: { $0.type == type }) {
            self.sections[index].products.append(product)
        }
    }
    
    private func updateProduct(_ product: StorageProduct) {
        self.removeProduct(id: product.id)
        
        guard product.state != ProductState.deleted.rawValue,
              product.state != ProductState.deletedOffline.rawValue else { return }
        
        self.addProduct(product)
    }
    
    private func removeProduct(id: String) {
        if let sectionIndex = self.sections.firstIndex(where: { section in
            section.products.contains(where: { $0.id == id })
        }) {
            self.sections[sectionIndex].products.removeAll { $0.id == id }
        }
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
    
    // MARK: - Methods. Public
    
    func loadStorageProducts() {
        self.isLoading = true
        
        self.dataStorage.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { products in
                self.storageProducts = products
                self.createSections(with: products)
            }
            .store(in: &subscriptions)
    }
    
    func createStorageProduct(_ product: StorageProduct) {
        isStorageSaveInProgress = true
        
        dataStorage.create(product)
            .handleEvents(receiveOutput: { created in
                self.addProduct(created)
            })
            .flatMap { [weak self] _ in
                self?.dataStorage.fetchAll()
                ?? Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.storageProducts = products
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &subscriptions)
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
        
        self.dataStorage.update(ids: [product.id], newState: finalState, isFavorite: product.isFavorite)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                self?.updateProduct(product)
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &subscriptions)
    }
    
    func updateSectionProductsStatus(sectionId: UUID) {
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
            let createdPublisher = dataStorage.update(ids: createdIDs, newState: .created, isFavorite: isFavorite)
            publishers.append(createdPublisher)
        }
        
        if !updatedIDs.isEmpty {
            let updatedPublisher = dataStorage.update(ids: updatedIDs, newState: .updated, isFavorite: isFavorite)
            publishers.append(updatedPublisher)
        }
        
        guard !publishers.isEmpty else { return }
        
        Publishers.MergeMany(publishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { [weak self] products in
                products.forEach { self?.updateProduct($0) }
                if NetworkMonitor.shared.isConnected {
                    self?.syncAllPendingProducts()
                }
            }
            .store(in: &subscriptions)
    }
    
    func syncAllPendingProducts() {
        let created = self.storageProducts
            .filter { $0.state == ProductState.created.rawValue }
            .map { convert($0) }
        let updated = self.storageProducts
            .filter { $0.state == ProductState.updated.rawValue }
            .map { convert($0) }
        let deleted = self.storageProducts
            .filter { $0.state == ProductState.deleted.rawValue }
            .map { convert($0) }

        if !created.isEmpty {
            self.createProducts(created)
        }
        if !updated.isEmpty {
            self.updateProductsStatus(updated)
        }
        if !deleted.isEmpty {
            self.deleteProducts(deleted)
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
    
    func searchProducts(query: String) {
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
            .store(in: &subscriptions)
    }
    
    func createProducts(_ newProducts: [Product]) {
        let delayPerRequest = 1.0
        self.isLoading = true
        
        let sequence = Publishers.Sequence(sequence: newProducts)
            .flatMap(maxPublishers: .max(25)) { product in
                self.apiClient.createProduct(product)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .seconds(delayPerRequest), scheduler: DispatchQueue.main)
                    .flatMap { [weak self] createdProduct -> AnyPublisher<[StorageProduct], Never> in
                        guard let self else { return Just([]).eraseToAnyPublisher() }
                        
                        return self.dataStorage.update(ids: [createdProduct.id], newState: .synced)
                            .handleEvents(receiveOutput: { _ in })
                            .catch { error in
                                Just([StorageProduct]()).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
            }
        
        sequence
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func updateProductsStatus(_ products: [Product]) {
        let delayPerRequest = 1.0
        self.isLoading = true
        
        let sequence = Publishers.Sequence(sequence: products)
            .flatMap(maxPublishers: .max(25)) { product in
                self.apiClient.updateProductStatus(id: product.id, isFavourite: product.isFavorite)
                    .receive(on: DispatchQueue.main)
                    .delay(for: .seconds(delayPerRequest), scheduler: DispatchQueue.main)
                    .flatMap { [weak self] updateProduct -> AnyPublisher<[StorageProduct], Never> in
                        guard let self else { return Just([]).eraseToAnyPublisher() }
                        
                        return self.dataStorage.update(ids: [updateProduct.id], newState: .synced)
                            .handleEvents(receiveOutput: { updated in
                            })
                            .catch { error in
                                Just([StorageProduct]()).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
            }
        
        sequence
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func deleteProducts(_ products: [Product]) {
        let delayPerRequest: TimeInterval = 1.0
        isLoading = true
        
        let sequence = Publishers.Sequence(sequence: products)
            .flatMap(maxPublishers: .max(25)) { product in
                self.apiClient.deleteProduct(id: product.id)
                    .receive(on: DispatchQueue.global())
                    .delay(for: .seconds(delayPerRequest), scheduler: DispatchQueue.global())
                    .flatMap { [weak self] productId in
                        guard let self = self else {
                            return Fail<String, APIError>(error: .deleteFailed)
                                .eraseToAnyPublisher()
                        }
                        return self.dataStorage
                            .delete(id: productId)
                            .handleEvents(receiveOutput: { id in
                                self.removeProduct(id: id)
                            })
                            .eraseToAnyPublisher()
                    }
            }
            .receive(on: DispatchQueue.main)
        
        sequence
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in
            }
            .store(in: &subscriptions)
    }
    
    func deleteOfflineProducts() {
        self.isLoading = true
        
        let products = self.storageProducts.filter { $0.state == ProductState.deletedOffline.rawValue }
        
        guard !products.isEmpty else {
            self.isLoading = false
            return
        }
        
        let publishers = products.map { product in
            self.dataStorage.delete(id: product.id)
                .handleEvents(receiveOutput: { [weak self] id in
                    self?.removeProduct(id: id)
                })
                .eraseToAnyPublisher()
        }
        
        Publishers.MergeMany(publishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handleCompletion(completion)
            } receiveValue: { _ in }
            .store(in: &subscriptions)
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
