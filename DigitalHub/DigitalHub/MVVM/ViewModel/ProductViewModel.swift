//
//  ProductViewModel.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

import SwiftUI
import Combine

struct ContentView3: View {
    @State private var products: [Product] = []
    @State private var errorMessage: String = ""
    private let client: ProductApiClientProtocol = MoyaClient()
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Button("Load Products") {
                client.getProducts()
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            errorMessage = error.errorDescription ?? "Unknown error"
                            print("Ошибка получения продуктов: \(error.errorDescription ?? "Unknown error")")
                        case .finished:
                            break
                        }
                    } receiveValue: { products in
                        self.products = products
                        print("Получено продуктов: \(products.count)")
                    }
                    .store(in: &cancellables)
            }
            .padding()
            
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
            if products.isEmpty {
                Text("No products loaded")
                    .padding()
            } else {
                List(products, id: \.id) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                        Text(product.id)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
    }
}


struct ContentView3_Previews: PreviewProvider {
    static var previews: some View {
        ContentView3()
    }
}
