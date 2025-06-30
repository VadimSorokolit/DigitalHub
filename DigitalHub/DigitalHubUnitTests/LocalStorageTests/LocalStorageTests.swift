//
//  LocalStorageTests.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 30.06.2025.
//

import XCTest
import SwiftData
import Combine
@testable import DigitalHub

final class LocalStorageTests: XCTestCase {
    
    // MARK: - Properties
    
    private var container: ModelContainer!
    private var context: ModelContext!
    private var storage: LocalStorage!
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - SetUp methods
    
    override func setUpWithError() throws {
        let schema = Schema([StorageProduct.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        self.container = try ModelContainer(for: schema, configurations: [config])
        self.context = ModelContext(container)
        self.storage = LocalStorage(context: context)
    }
    
    override func tearDownWithError() throws {
        self.container = nil
        self.context = nil
        self.storage = nil
        self.subscriptions.removeAll()
        
        try super.tearDownWithError()
    }
    
    // MARK: - Test Methods
    
    func test_fetchAllProducts() {
        let expectation = XCTestExpectation(description: "Fetch all products")
        
        self.storage.fetchAllProducts()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { products in
                print(products.count)
                XCTAssertEqual(products.count, 0)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_searchProducts() {
        let expectation = XCTestExpectation(description: "Search products")
        
        let newProduct1 = StorageProduct()
        newProduct1.name = "Test Product 1"
        newProduct1.price = "10"
        
        let newProduct2 = StorageProduct()
        newProduct2.name = "Producttest2"
        newProduct2.price = "20"
        
        let newProduct3 = StorageProduct()
        newProduct3.name = "AnotherTestProduct"
        newProduct3.price = "30"
        
        self.storage.createProduct(newProduct1)
            .flatMap { _ in
                self.storage.createProduct(newProduct2)
            }
            .flatMap { _ in
                self.storage.createProduct(newProduct3)
            }
            .flatMap { _ in
                self.storage.searchProducts(query: "Test")
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { foundProducts in
                
                XCTAssertEqual(foundProducts.count, 3)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_createProduct() {
        let expectation = XCTestExpectation(description: "Create product")
        
        let newProduct = StorageProduct()
        newProduct.name = "Test Product"
        newProduct.price = "10"
        
        self.storage.createProduct(newProduct)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { createdProduct in
                
                XCTAssertNotNil(createdProduct)
                XCTAssertEqual(newProduct.id, createdProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_updateProduct() {
        let expectation = XCTestExpectation(description: "Update product")
        
        let newProduct = StorageProduct()
        newProduct.name = "Test Product Updated"
        newProduct.isFavorite = false
        newProduct.price = "100"
        
        self.storage.createProduct(newProduct)
            .flatMap { createdProduct in
                return self.storage.updateProduct(ids: [createdProduct.id], newState: .updated, isFavorite: createdProduct.isFavorite)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { updatedProducts in
                
                XCTAssertEqual(updatedProducts.count, 1)
                
                let updatedProduct = updatedProducts.first
                
                XCTAssertEqual(updatedProduct?.state, ProductState.updated.rawValue)
                XCTAssertEqual(updatedProduct?.isFavorite, true)
                XCTAssertEqual(updatedProduct?.isFavorite, newProduct.isFavorite)
                XCTAssertEqual(updatedProduct?.id, newProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_deleteProduct() {
        let expectation = XCTestExpectation(description: "Delete product")
        
        let newProduct = StorageProduct()
        newProduct.name = "Test Product Deleted"
        newProduct.isFavorite = false
        newProduct.price = "100"
        
        self.storage.createProduct(newProduct)
            .flatMap { createdProduct in
                return self.storage.deleteProduct(id: createdProduct.id)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { deletedProductId in
                
                XCTAssertNotNil(deletedProductId)
                XCTAssertEqual(deletedProductId, newProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
}
