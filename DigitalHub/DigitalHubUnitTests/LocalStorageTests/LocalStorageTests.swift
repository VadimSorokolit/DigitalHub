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
        self.context = ModelContext(self.container)
        self.storage = LocalStorage(context: self.context)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.container = nil
        self.context = nil
        self.storage = nil
        self.subscriptions.removeAll()
    }
    
    // MARK: - Test Methods
    
    func test_fetchAllProducts() {
        let expectation = XCTestExpectation(description: "Fetch all products")
        
        self.storage.fetchAllProducts()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { products in
                
                XCTAssertTrue(products.isEmpty)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_searchProducts() {
        let expectation = XCTestExpectation(description: "Search products")
        
        let testProduct1 = StorageProduct()
        testProduct1.name = "TestProduct\(UUID().uuidString)"
        testProduct1.price = "10"
        
        let testProduct2 = StorageProduct()
        testProduct2.name = "Producttest2\(UUID().uuidString)"
        testProduct2.price = "20"
        
        let testProduct3 = StorageProduct();
        testProduct3.name = "AnotherTestProduct\(UUID().uuidString)"
        testProduct3.price = "30"
        
        let testProduct4 = StorageProduct(); 
        testProduct4.name = "AnotherTeProduct\(UUID().uuidString)"
        testProduct4.price = "40"
        
        let testProduct5 = StorageProduct()
        testProduct5.name = "LastPstroduct\(UUID().uuidString)"
        testProduct5.price = "50"
        
        let testProducts = [testProduct1, testProduct2, testProduct3, testProduct4, testProduct5]
        let query = "Test"
        let expectedQueryProuductsCount = testProducts.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }.count
        
        Publishers.Sequence(sequence: testProducts)
            .flatMap {
                self.storage.createProduct($0)
            }
            .collect()
            .flatMap { _ in
                self.storage.searchProducts(query: query)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { foundProducts in
                
                XCTAssertEqual(foundProducts.count, expectedQueryProuductsCount)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_createProduct() {
        let expectation = XCTestExpectation(description: "Create product")
        
        let testProduct = StorageProduct()
        testProduct.name = "Test Product"
        testProduct.price = "10"
        
        self.storage.createProduct(testProduct)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { createdProduct in
                
                XCTAssertNotNil(createdProduct)
                XCTAssertEqual(testProduct.id, createdProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_updateProduct() {
        let expectation = XCTestExpectation(description: "Update product")
        
        let testProduct = StorageProduct()
        testProduct.name = "Test Product Updated"
        testProduct.isFavorite = false
        testProduct.price = "100"
        
        self.storage.createProduct(testProduct)
            .flatMap { createdProduct in
                return self.storage.updateProduct(ids: [createdProduct.id], newState: .updated, isFavorite: !createdProduct.isFavorite)
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
                XCTAssertEqual(updatedProduct?.isFavorite, testProduct.isFavorite)
                XCTAssertEqual(updatedProduct?.id, testProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_deleteProduct() {
        let expectation = XCTestExpectation(description: "Delete product")
        
        let testProduct = StorageProduct()
        testProduct.name = "Test Product Deleted"
        testProduct.isFavorite = false
        testProduct.price = "100"
        
        self.storage.createProduct(testProduct)
            .flatMap { createdProduct in
                return self.storage.deleteProduct(id: createdProduct.id)
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { deletedProductId in
                
                XCTAssertNotNil(deletedProductId)
                XCTAssertEqual(deletedProductId, testProduct.id)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
}
