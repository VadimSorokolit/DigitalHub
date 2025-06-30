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
        var receivedList: ProductList?
        
        self.requireClient().getProducts(startingAfterId: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        
                        XCTFail("Error: \(error.localizedDescription)")
                        
                    case .finished:
                        break
                }
            }, receiveValue: { list in
                receivedList = list
                expectation.fulfill()
            })
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(receivedList)
    }
    
    func test_searchProducts() {
        let expectation = XCTestExpectation(description: "Search products")
        
        let newProducts = [
            Product(name: "AliOne"),
            Product(name: "Twoali"),
            Product(name: "Thaliree")
        ]
        
        let expectedPrefix = "Ali"
        let expectedCount = 3
        let searchDelay: TimeInterval = 60.0 /** Delay to ensure Stripe has indexed the newly created products for search
                                              https://docs.stripe.com/search?utm_source=chatgpt.com#data-freshnes
                                              */
        Publishers.Sequence(sequence: newProducts)
            .flatMap(maxPublishers: .max(1)) { self.requireClient().createProduct($0) }
            .collect()
            .delay(for: .seconds(searchDelay), scheduler: DispatchQueue.global())
            .flatMap { _ in
                self.requireClient().searchProducts(name: expectedPrefix, startingAfterId: nil)
            }
            .flatMap { productList in
                
                XCTAssertEqual(productList.products.count, expectedCount)
                
                let deletePublishers = productList.products.map { self.requireClient().deleteProduct(id: $0.id) }
                return Publishers.MergeMany(deletePublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { deletedIds in
                
                XCTAssertEqual(deletedIds.count, expectedCount)
                
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        self.wait(for: [expectation], timeout: 65.0)
    }
    
    func test_createFile() {
        let expectation = XCTestExpectation(description: "Create file expectation")
        
        guard let image = UIImage(systemName: "star") else {
            
            XCTFail( "Failed to load image")
            
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            
            XCTFail("Failed to get data from image")
            
            return
        }
        
        self.requireClient().createFile(data)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { imageFile in
                
                XCTAssertFalse(imageFile.id.isEmpty)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_createFileLink() {
        let expectation = XCTestExpectation(description: "Create file link expectation")
        
        guard let image = UIImage(systemName: "house") else {
            
            XCTFail("Failed to load image")
            
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            
            XCTFail("Failed to get data from image")
            
            return
        }
        self.requireClient().createFile(data)
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
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_createProduct() {
        let expectation = XCTestExpectation(description: "Create product")
        
        let newProduct = Product(name: "TestProductName", brandName: "TestBrandName", price: "100", discount: "20")
        
        self.requireClient().createProduct(newProduct)
            .flatMap { [self] createdProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertEqual(createdProduct.name, newProduct.name)
                XCTAssertFalse(createdProduct.id.isEmpty)
                
                return self.requireClient().deleteProduct(id: createdProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(deletedId, newProduct.id)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_updateProductStatusAndDelete() {
        let expectation = XCTestExpectation(description: "Update status product")
        
        let newProduct = Product(name: "TestProductName", brandName:  "TestBrandName", isFavorite: false, price: "100", discount: "20")
        
        self.requireClient().createProduct(newProduct)
            .flatMap { createdProduct -> AnyPublisher<Product, APIError> in
                
                XCTAssertEqual(createdProduct.name, newProduct.name)
                
                return self.self.requireClient().updateProductStatus(id: createdProduct.id, isFavorite: true)
            }
            .flatMap { updatedProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertTrue(updatedProduct.isFavorite)
                XCTAssertNotEqual(updatedProduct.isFavorite, newProduct.isFavorite)
                
                return self.requireClient().deleteProduct(id: updatedProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(newProduct.id, deletedId)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }
    
    func test_DeleteProduct() {
        let expectation = XCTestExpectation(description: "Delete product")
        
        let newProduct = Product(name: "NewTestProductName", brandName: "NewTestBrandName", price: "200", discount: "40")
        
        self.requireClient().createProduct(newProduct)
            .flatMap { [self] createdProduct -> AnyPublisher<String, APIError> in
                
                XCTAssertEqual(createdProduct.name, newProduct.name)
                XCTAssertFalse(createdProduct.id.isEmpty)
                
                return self.requireClient().deleteProduct(id: createdProduct.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { deletedId in
                
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(deletedId, newProduct.id)
                
                expectation.fulfill()
            }
            .store(in: &self.subscriptions)
        
        self.wait(for: [expectation], timeout: 5.0)
    }

}
