//
//  DigitalHubUITestsLaunchTests.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    

import XCTest
import Combine
@testable import DigitalHub  // Замените на имя вашего модуля

class MoyaClientTests: XCTestCase {
    var client: MoyaClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        client = MoyaClient()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        client = nil
        super.tearDown()
    }
    
    // Тест для получения списка продуктов
    func testGetProducts() {
        let expectation = self.expectation(description: "Get Products")
        
        client.getProducts()
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Ошибка получения продуктов: \(error)")
                }
            } receiveValue: { products in
                print("Получено продуктов: \(products.count)")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Тест для создания продукта
    func testCreateProduct() {
        let expectation = self.expectation(description: "Create Product")
        
        client.createProdutWith(name: "Audi", id: "prod_new_audi")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Ошибка создания продукта: \(error)")
                }
            } receiveValue: { product in
                print("Создан продукт: \(product)")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Тест для удаления продукта
    func testDeleteProduct() {
        let expectation = self.expectation(description: "Delete Product")
        
        client.deleteProductById("prod_new_audi")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Ошибка удаления продукта: \(error)")
                }
            } receiveValue: { _ in
                print("Продукт успешно удалён")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
