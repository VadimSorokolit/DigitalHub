//
//  DigitalHubApp.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI
import SwiftData

@main
struct DigitalHubApp: App {
    
    // MARK: - Properties
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DigitalProduct.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var viewModel: ProductsViewModel = ProductsViewModel(apiClient: MoyaClient())
    @State private var showSpinner: Bool = false
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ProductsView(viewModel: viewModel)
                    .modifier(LoadViewModifier(viewModel: viewModel, showSpinner: $showSpinner))
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    struct LoadViewModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var showSpinner: Bool
        
        func body(content: Content) -> some View {
            content
            ZStack {
                if showSpinner {
                    SpinnerView()
                }
            }
            .onAppear {
                viewModel.loadFirstPage()
            }
            .onReceive(viewModel.$isLoading) { isLoading in
                showSpinner = isLoading
            }
        }
    }
    
}
