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
    private var subscription = Set<AnyCancellable>()
    private var client: MoyaClient?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        guard NetworkMonitor.shared.isConnected else {
            throw XCTSkip("No internet connection")
        }
        client = MoyaClient()
    }
    
    override func tearDown() {
        super.tearDown()
        
        subscription.removeAll()
        client = nil
    }
    
    func requireClient() -> MoyaClient {
        guard let client = client else {
            
            XCTFail("Client is nil")
            
            fatalError("Client must not be nil")
        }
        return client
    }
    
    func test_getProducts() {
        let expectation = XCTestExpectation(description: "Product list expectation")
        var receivedList: ProductList?
        
        requireClient().getProducts(startingAfterId: nil)
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
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(((receivedList?.products.isEmpty) != nil))
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
        
        requireClient().createFile(data)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { imageFile in
                XCTAssertFalse(imageFile.id.isEmpty)
                expectation.fulfill()
            }
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
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
        requireClient().createFile(data)
            .flatMap { [self] imageFile -> AnyPublisher<ImageFileLink, APIError> in
                XCTAssertFalse(imageFile.id.isEmpty)
                
                return requireClient().createFileLink(imageFile.id)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                }
            } receiveValue: { fileLink in
                XCTAssertFalse(fileLink.url.isEmpty)
                expectation.fulfill()
            }
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_createProduct() {
        let expectation = XCTestExpectation(description: "Create product expectation")
        
        let product = Product(name: "TestProductName")
        
        requireClient().createProduct(product)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { createdProduct in
                
                XCTAssertEqual(createdProduct.name, product.name)
                
                expectation.fulfill()
            })
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_updateProductStatus() {
        let expectation = XCTestExpectation(description: "Update product status expectation")
        
        let product = Product(name: "TestProductName", brandName: "TestBrandName", isFavorite: false, price: "100", discount: "20")
        
        requireClient().createProduct(product)
            .flatMap { createdProduct -> AnyPublisher<Product, APIError> in
                
                XCTAssertEqual(createdProduct.name, product.name)
                
                return self.requireClient().updateProductStatus(id: createdProduct.id, isFavorite: true)
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { updatedProduct in
                XCTAssertEqual(product.id, updatedProduct.id)
                XCTAssertNotEqual(product.isFavorite, updatedProduct.isFavorite)
                XCTAssertTrue(updatedProduct.isFavorite)
                expectation.fulfill()
            })
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_deleteProduct() {
        let expectation = XCTestExpectation(description: "Create and delete product")
        
        let product = Product(name: "TestProductName1", brandName: "TestBrandName1", isFavorite: false, price: "122", discount: "22")
        
        requireClient().createProduct(product)
            .flatMap { createdProduct -> AnyPublisher<String, APIError> in
                XCTAssertEqual(createdProduct.name, product.name)
                return self.requireClient().deleteProduct(id: createdProduct.id)
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Error : \(error.localizedDescription)")
                }
            }, receiveValue: { deletedId in
                XCTAssertFalse(deletedId.isEmpty)
                XCTAssertEqual(product.id, deletedId)
                expectation.fulfill()
            })
            .store(in: &subscription)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
