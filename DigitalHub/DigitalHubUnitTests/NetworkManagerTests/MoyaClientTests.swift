//
//  MoyaClientTests.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.06.2025.
//

import XCTest
import Combine
@testable import DigitalHub

final class MoyaClientTests: XCTestCase {
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    private var client: MoyaClient?
    private var defaultExpectationTimeout: TimeInterval = 5.0
    
    // MARK: - SetUp methods
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        guard NetworkMonitor.shared.isConnected else {
            throw XCTSkip("No internet connection")
        }
        self.client = MoyaClient()
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.subscriptions.removeAll()
        self.client = nil
    }
    
    func requireClient() -> MoyaClient {
        guard let client = self.client else {
            
            XCTFail("Client is nil")
            
            fatalError("Client must not be nil")
        }
        return client
    }
    
    // MARK: - Test methods
    
    func test_getProducts() {
        let expectation = XCTestExpectation(description: "Product list expectation")
        
        self.requireClient().getProducts(startingAfterId: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        
                        XCTFail("Error: \(error.localizedDescription)")
                        
                    case .finished:
                        break
                }
            }, receiveValue: { list in
                
                XCTAssertNotNil(list)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
    func test_searchProducts() {
        let expectation = XCTestExpectation(description: "Search products")
        
        let testProducts = [
            Product(name: "testAliOne\(UUID().uuidString)"),
            Product(name: "testTwoali\(UUID().uuidString)"),
            Product(name: "testThaliree\(UUID().uuidString)"),
            Product(name: "testFourai\(UUID().uuidString)"),
            Product(name: "testA\(UUID().uuidString)")
        ]
        
        let query = "Ali"
        let expectedQueryProductsCount = testProducts.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }.count
        
        /**
         Delay to ensure search API has indexed the newly created products
         https://docs.stripe.com/search?utm_source=chatgpt.com#data-freshnes
         */
        let searchDelay: TimeInterval = 60.0
        
        Publishers.Sequence(sequence: testProducts)
            .flatMap(maxPublishers: .max(1)) {
                self.requireClient().createProduct($0)
            }
            .collect()
            .delay(for: .seconds(searchDelay), scheduler: DispatchQueue.global())
            .flatMap { _ in
                self.requireClient().searchProducts(query: query, startingAfterId: nil)
            }
            .flatMap { productList in
                
                XCTAssertEqual(productList.products.count, expectedQueryProductsCount)
                
                let deletePublishers = testProducts.map {
                    self.requireClient().deleteProduct(id: $0.id)
                }
                return Publishers.MergeMany(deletePublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { deletedIds in
                
                XCTAssertEqual(deletedIds.count, testProducts.count)
                
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: searchDelay + self.defaultExpectationTimeout)
    }
    
    func test_createFile() {
        let expectation = XCTestExpectation(description: "Create file expectation")
        
        guard let testImage = UIImage(systemName: "star") else {
            
            XCTFail( "Failed to load image")
            
            return
        }
        guard let testData = testImage.jpegData(compressionQuality: 0.8) else {
            
            XCTFail("Failed to get data from image")
            
            return
        }
        self.requireClient().createFile(testData)
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { imageFile in
                
                XCTAssertFalse(imageFile.id.isEmpty)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
    func test_createFileLink() {
        let expectation = XCTestExpectation(description: "Create file link expectation")
        
        guard let testImage = UIImage(systemName: "house") else {
            
            XCTFail("Failed to load image")
            
            return
        }
        guard let testData = testImage.jpegData(compressionQuality: 0.8) else {
            
            XCTFail("Failed to get data from image")
            
            return
        }
        self.requireClient().createFile(testData)
            .flatMap { [self] imageFile -> AnyPublisher<ImageFileLink, APIError> in
                
                XCTAssertFalse(imageFile.id.isEmpty)
                
                return self.requireClient().createFileLink(imageFile.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { fileLink in
                
                XCTAssertFalse(fileLink.url.isEmpty)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
    func test_createProduct() {
        let expectation = XCTestExpectation(description: "Create product")
        
        let testProduct = Product(name: "TestProductName", brandName: "TestBrandName", price: "100", discount: "20")
        
        self.requireClient().createProduct(testProduct)
            .flatMap { [self] createdProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertEqual(createdProduct.name, testProduct.name)
                XCTAssertFalse(createdProduct.id.isEmpty)
                
                return self.requireClient().deleteProduct(id: createdProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(deletedId, testProduct.id)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
    func test_updateProduct() {
        let expectation = XCTestExpectation(description: "Update product status")
        
        let testProduct = Product(name: "TestProductName", brandName:  "TestBrandName", isFavorite: false, price: "100", discount: "20")
        
        self.requireClient().createProduct(testProduct)
            .flatMap { createdProduct -> AnyPublisher<Product, APIError> in
                
                XCTAssertEqual(createdProduct.name, testProduct.name)
                
                return self.self.requireClient().updateProductStatus(id: createdProduct.id, isFavorite: true)
            }
            .flatMap { updatedProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertTrue(updatedProduct.isFavorite)
                XCTAssertNotEqual(updatedProduct.isFavorite, testProduct.isFavorite)
                
                return self.requireClient().deleteProduct(id: updatedProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(testProduct.id, deletedId)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
    func test_DeleteProduct() {
        let expectation = XCTestExpectation(description: "Delete product")
        
        let testProduct = Product(name: "NewTestProductName", brandName: "NewTestBrandName", price: "200", discount: "40")
        
        self.requireClient().createProduct(testProduct)
            .flatMap { [self] createdProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertEqual(createdProduct.name, testProduct.name)
                XCTAssertFalse(createdProduct.id.isEmpty)
                
                return self.requireClient().deleteProduct(id: createdProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(deletedId, testProduct.id)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: self.defaultExpectationTimeout)
    }
    
}
