//
//  DigitalHubApp.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI
import SwiftData

@main
private struct DigitalHubApp: App {
    
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: ProductsViewModel
    @StateObject private var networkMonitor: NetworkMonitor
    @State private var didLoadProducts = false
    @State private var showSpinner: Bool = false
    private let sharedModelContainer: ModelContainer
    
    // MARK: - Initializer
    
    init() {
#if DEBUG
        //        Self.resetStorageIfNeeded()
#endif
        let schema = Schema([StorageProduct.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            
            let context = container.mainContext
            let dataStorage = LocalStorage(context: context)
            let viewModel = ProductsViewModel(dataStorage: dataStorage, apiClient: MoyaClient())
            let monitor = NetworkMonitor.shared
            
            _viewModel = StateObject(wrappedValue: viewModel)
            _networkMonitor = StateObject(wrappedValue: monitor)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    private static func resetStorageIfNeeded() {
        let fileManager = FileManager.default
        
        let baseURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        
        let storeURL = baseURL.appendingPathComponent("default.store")
        
        if fileManager.fileExists(atPath: storeURL.path) {
            do {
                try fileManager.removeItem(at: storeURL)
                print("SwiftData cleaned: \(storeURL.path)")
            } catch {
                print(error)
            }
        } else {
            print(storeURL.path)
        }
    }
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ProductsView(viewModel: viewModel, networkMonitor: networkMonitor)
                    .modifier(LoadViewModifier(viewModel: viewModel, networkMonitor: networkMonitor, didLoadProducts: $didLoadProducts, showSpinner: $showSpinner))
            }
            .statusBar(hidden: true)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private struct LoadViewModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @ObservedObject var networkMonitor: NetworkMonitor
        @Binding var didLoadProducts: Bool
        @Binding var showSpinner: Bool
        
        func body(content: Content) -> some View {
            ZStack {
                content
                
                if showSpinner {
                    SpinnerView()
                }
            }
            .onAppear {
                if !didLoadProducts {
                    viewModel.loadStorageProducts()
                    didLoadProducts = true
                }
            }
            .onChange(of: viewModel.isLoading) {
                if viewModel.isLoading {
                    showSpinner = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSpinner = false
                    }
                }
            }
        }
    }
    
}
