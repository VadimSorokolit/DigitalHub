//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI
import SDWebImageSwiftUI

struct ProductsView: View {
    
    // MARK: - Objects
    
    private struct Constants {
        static let headerTitleName: String = "Products"
        static let headerImageName: String = "logoImage"
        static let cancelButtonImageName: String = "xmark.circle.fill"
        static let headerButtonImageName: String = "plusButtonImage"
        static let searchBarImageName: String = "magnifyingglass"
        static let searchBarPlaceholder: String = "Search"
        static let headerTitleFontColor: Int = 0x1F2937
        static let searchBarImageColor: Int = 0x9CA3AF
        static let searchBarPlaceholderColor: Int = 0x9CA3AF
        static let searchBarColor: Int = 0xE6E7E9
        static let sectionTitleColor: Int = 0x1F2937
        static let sectionSubtitleColor: Int = 0x6B7280
        static let sectionButtonTitleColor: Int = 0x6B7280
        static let sectionButtonImageColor: Int = 0x89909E
        static let priceValueColor: Int = 0xFFFFFF
        static let discountValueColor: Int = 0xFFFFFF
        static let textLineCount: Int = 3
        static let headerTitleImageSize: CGFloat = 30.0
        static let headerTitleFontSize: CGFloat = 20.0
        static let productsListInterSectionSpacing: CGFloat = 36.0
        static let productsHeaderTextSpacing: CGFloat = 4.0
        static let favoriteProductImageWidth: CGFloat = 128.0
        static let favoriteProductImageHeight: CGFloat = 100.0
        static let favoriteCellCornerRadius: CGFloat = 16.0
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @ObservedObject var networkMonitor: NetworkMonitor
    @State private var path: NavigationPath = NavigationPath()
    @State private var searchQuery: String = ""
    @State private var canShowAlert: Bool = false
    @State private var isShowingAlert: Bool = false
    
    // MARK: - Main body
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28.0) {
                    HeaderView(path: $path, searchQuery: $searchQuery)
                    if searchQuery.isEmpty {
                        ProductsListView(viewModel: viewModel, path: $path, canShowAlert: $canShowAlert, isShowingAlert: $isShowingAlert)
                    } else {
                        FilteredListView(viewModel: viewModel)
                    }
                }
            }
            .modifier(ScreenBackgroundModifier())
            .modifier(SectionNavigationModifier(viewModel: viewModel, networMonitor: networkMonitor))
            .modifier(LoadViewModifier(viewModel: viewModel, searchQuery: $searchQuery))
            .modifier(AlertViewModifier(isShowingAlert: $isShowingAlert, canShowAlert: $canShowAlert))
        }
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        @Binding var path: NavigationPath
        @Binding var searchQuery: String
        
        var body: some View {
            VStack(spacing: 18.0) {
                TitleView(path: $path)
                SearchBarView(searchQuery: $searchQuery)
            }
            .padding(.top, 34.0)
            .padding(.horizontal, 18.0)
        }
        
        private struct TitleView: View {
            @Binding var path: NavigationPath
            
            var body: some View {
                ZStack {
                    TitleWithImage()
                    ImageButton(path: $path)
                }
            }
            
            private struct TitleWithImage: View {
                
                var body: some View {
                    Text(Constants.headerTitleName)
                        .font(.custom(GlobalConstants.mediumFont, size: Constants.headerTitleFontSize))
                        .foregroundColor(Color(hex: Constants.headerTitleFontColor))
                        .overlay(
                            Image(Constants.headerImageName)
                                .resizable()
                                .frame(width: Constants.headerTitleImageSize, height: Constants.headerTitleImageSize)
                                .scaledToFit()
                                .offset(x: -50.0),
                            alignment: .leading
                        )
                }
                
            }
            
            private struct ImageButton: View {
                @Binding var path: NavigationPath
                
                var body: some View {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            path.append("goToAddProductScreen")
                        }) {
                            Image(Constants.headerButtonImageName)
                                .resizable()
                                .frame(width: Constants.headerTitleImageSize, height: Constants.headerTitleImageSize)
                                .scaledToFit()
                        }
                    }
                }
                
            }
            
        }
        
        private struct SearchBarView: View {
            
            @Binding var searchQuery: String
            
            var body: some View {
                HStack {
                    Image(systemName: Constants.searchBarImageName)
                        .foregroundColor(Color(hex: Constants.searchBarImageColor))
                        .padding(.leading, 11.0)
                    
                    TextField(Constants.searchBarPlaceholder, text: $searchQuery)
                        .font(.custom(GlobalConstants.regularFont, size: 16.0))
                        .foregroundColor(.black)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.leading, 7.0)
                    
                    Spacer()
                    
                    Button(action: {
                        searchQuery.removeAll()
                    }) {
                        if !searchQuery.isEmpty {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: 0x737475))
                                .scaledToFit()
                                .frame(width: 20.0, height: 20.0)
                        }
                    }
                    .padding(.trailing, 8.0)
                }
                .frame(height: 36.0)
                .background(Color(hex: Constants.searchBarColor))
                .cornerRadius(11.0)
            }
            
        }
        
    }
    
    private struct ProductsListView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var path: NavigationPath
        @Binding var canShowAlert: Bool
        @Binding var isShowingAlert: Bool
        
        var body: some View {
            VStack(spacing: Constants.productsListInterSectionSpacing) {
                ForEach(viewModel.sections, id: \.id) { section in
                    if section.type == .favorites, !section.products.isEmpty {
                        SectionFavorites(viewModel: viewModel, path: $path, canShowAlert: $canShowAlert, isShowingAlert: $isShowingAlert, sectionId: section.id)
                    }
                    if section.type == .unfavorites, !section.products.isEmpty {
                        SectionUnfavorites(viewModel: viewModel, path: $path, canShowAlert: $canShowAlert, isShowingAlert: $isShowingAlert, sectionId: section.id)
                    }
                }
            }
        }
        
        private struct SectionFavorites: View {
            @ObservedObject var viewModel: ProductsViewModel
            @Binding var path: NavigationPath
            @Binding var canShowAlert: Bool
            @Binding var isShowingAlert: Bool
            let sectionId: UUID
            
            var body: some View {
                if let section = viewModel.section(withId: sectionId) {
                    VStack(alignment: .leading, spacing: 16.0) {
                        HeaderView(viewModel: viewModel, path: $path, sectionId: sectionId)
                        ListView(viewModel: viewModel, canShowAlert: $canShowAlert, isShowingAlert: $isShowingAlert, sectionId: section.id)
                    }
                }
            }
            
            private struct HeaderView: View {
                @ObservedObject var viewModel: ProductsViewModel
                @Binding var path: NavigationPath
                let sectionId: UUID
                
                var body: some View {
                    if let section = viewModel.section(withId: sectionId) {
                        HStack {
                            VStack(alignment: .leading, spacing: Constants.productsHeaderTextSpacing) {
                                Text(section.title)
                                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                    .foregroundColor(Color(hex: Constants.sectionTitleColor))
                                
                                Text(section.subtitle)
                                    .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                                    .foregroundColor(Color(hex: Constants.sectionSubtitleColor))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                path.append(section.id)
                            }) {
                                HStack(spacing: 6.0) {
                                    Text(section.buttonTitle)
                                        .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                                        .foregroundColor(Color(hex: Constants.sectionButtonTitleColor))
                                    
                                    Image(systemName: section.buttonImageName)
                                        .resizable()
                                        .frame(width: 5.0, height: 8.75)
                                        .foregroundColor(Color(hex:Constants.sectionButtonImageColor))
                                }
                            }
                        }
                        .padding(.horizontal, 18.0)
                    }
                }
                
            }
            
            private struct ListView: View {
                @ObservedObject var viewModel: ProductsViewModel
                @Binding var canShowAlert: Bool
                @Binding var isShowingAlert: Bool
                let sectionId: UUID
                
                var body: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        if let section = viewModel.section(withId: sectionId) {
                            HStack(alignment: .top, spacing: 12.0) {
                                ForEach(section.products, id: \.id) { product in
                                    CellView(product: product, onLikeToogle: {
                                        viewModel.updateStorageProductStatus(product, newState: .updated)
                                    })
                                    .background(
                                        Group {
                                            if product == section.products.last {
                                                GeometryReader { proxy in
                                                    Color.clear
                                                        .onChange(of: proxy.frame(in: .global)) { oldFrame, newFrame in
                                                            let screenWidth = UIScreen.main.bounds.width
                                                            if newFrame.maxX <= screenWidth {
                                                                if viewModel.hasMoreData, !viewModel.isPagination {
                                                                    viewModel.loadNextPage()
                                                                } else if !viewModel.hasMoreData, !viewModel.isPagination {
                                                                    canShowAlert = true
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                                        isShowingAlert = true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                }
                                                .frame(width: 0.0, height: 0.0)
                                            }
                                        }
                                    )
                                }
                                if viewModel.isPagination {
                                    ZStack {
                                        Color.white
                                        ProgressView()
                                            .tint(Color(hex: Constants.searchBarPlaceholderColor))
                                    }
                                    .frame(
                                        width: Constants.favoriteProductImageWidth,
                                        height: 1.5 * Constants.favoriteProductImageWidth
                                    )
                                    .cornerRadius(Constants.favoriteCellCornerRadius)
                                }
                                
                                Spacer()
                                    .frame(width: 6.0, height: 0.1)
                            }
                            .padding(.leading, 18.0)
                        }
                    }
                }
                
                private struct CellView: View {
                    let product: StorageProduct
                    let onLikeToogle: () -> Void
                    
                    var body: some View {
                        VStack(spacing: 11.0) {
                            ImageView(product: product)
                            
                            VStack(alignment: .leading, spacing: 7.0) {
                                InfoView(product: product)
                                PriceView(product: product, onLikeToogle: onLikeToogle)
                            }
                        }
                        .padding([.top, .bottom, .horizontal], 10.0)
                        .background(Color(hex: GlobalConstants.productCellColor))
                        .cornerRadius(Constants.favoriteCellCornerRadius)
                    }
                    
                    private struct ImageView: View {
                        let product: StorageProduct
                        
                        var body: some View {
                            ZStack {
                                if product.imageURL == nil {
                                    Rectangle()
                                        .fill(Color(hex: GlobalConstants.cellImagePlaceholderBackgroundColor))
                                        .frame(width: Constants.favoriteProductImageWidth, height: Constants.favoriteProductImageHeight)
                                        .cornerRadius(8.0, corners: [.topLeft, .topRight])
                                }
                                
                                Group {
                                    if let urlString = product.imageURL, let url = URL(string: urlString) {
                                        WebImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: Constants.favoriteProductImageWidth, height: Constants.favoriteProductImageHeight)
                                        .clipped()
                                        .cornerRadius(8.0, corners: [.topLeft, .topRight])
                                    } else {
                                        Image(systemName: GlobalConstants.placeholderImageName)
                                            .resizable()
                                            .foregroundColor(Color(hex: GlobalConstants.cellImagePlaceholderColor))
                                            .frame(width: Constants.favoriteProductImageWidth / 2.0, height: Constants.favoriteProductImageHeight / 2.0)
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    private struct InfoView: View {
                        let product: StorageProduct
                        
                        var body: some View {
                            VStack(alignment: .leading, spacing: 4.0) {
                                Text(product.name)
                                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                    .foregroundColor(Color(hex: 0x1F2937))
                                
                                Text(product.brandName ?? "")
                                    .font(.custom(GlobalConstants.regularFont, size: 10.0))
                                    .foregroundColor(Color(hex: 0x6B7280))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(Constants.textLineCount)
                            .frame(width: Constants.favoriteProductImageWidth, alignment: .leading)
                        }
                        
                    }
                    
                    private struct PriceView: View {
                        let product: StorageProduct
                        let onLikeToogle: () -> Void
                        
                        var body: some View {
                            HStack {
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                        .fill(Color(hex: GlobalConstants.priceLabelColor))
                                        .frame(width: 50.0, height: 20.0)
                                        .cornerRadius(3.0, corners: [.topLeft, .topRight, .bottomRight])
                                        .cornerRadius(10.0, corners: [.bottomLeft])
                                        .overlay(
                                            Text(product.price ?? "--")
                                                .font(.custom(GlobalConstants.semiBoldFont, size: 8.0))
                                                .foregroundColor(Color(hex: Constants.priceValueColor)),
                                            alignment: .center
                                        )
                                    
                                    Rectangle()
                                        .fill(Color(hex: GlobalConstants.discountLabelColor))
                                        .frame(width: 23.0, height: 9.0)
                                        .cornerRadius(3.0)
                                        .overlay(
                                            Text(product.discount ?? "--")
                                                .font(.custom(GlobalConstants.semiBoldFont, size: 6.0))
                                                .foregroundColor(Color(hex: Constants.discountValueColor)),
                                            alignment: .center
                                        )
                                        .offset(x: 8.0, y: -3.0)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    onLikeToogle()
                                }) {
                                    Image(GlobalConstants.fillHeartImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20.0, height: 16.0)
                                }
                            }
                            .frame(width: Constants.favoriteProductImageWidth)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        private struct SectionUnfavorites: View {
            @ObservedObject var viewModel: ProductsViewModel
            @Binding var path: NavigationPath
            @Binding var canShowAlert: Bool
            @Binding var isShowingAlert: Bool
            let sectionId: UUID
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16.0) {
                    HeaderView(viewModel: viewModel, path: $path, sectionId: sectionId)
                    ListView(viewModel: viewModel, path: $path, canShowAlert: $canShowAlert, isShowingAlert: $isShowingAlert, sectionId: sectionId)
                }
            }
            
            private struct HeaderView: View {
                @ObservedObject var viewModel: ProductsViewModel
                @Binding var path: NavigationPath
                let sectionId: UUID
                
                var body: some View {
                    if let section = viewModel.section(withId: sectionId) {
                        HStack {
                            VStack(alignment: .leading, spacing: Constants.productsHeaderTextSpacing) {
                                Text(section.title)
                                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                    .foregroundColor(Color(hex: Constants.sectionTitleColor))
                                
                                Text(section.subtitle)
                                    .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                                    .foregroundColor(Color(hex: Constants.sectionSubtitleColor))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                path.append(section.id)
                            }) {
                                HStack(spacing: 6.0) {
                                    Text(section.buttonTitle)
                                        .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                                        .foregroundColor(Color(hex: Constants.sectionButtonTitleColor))
                                    
                                    Image(systemName: section.buttonImageName)
                                        .resizable()
                                        .frame(width: 5.0, height: 8.75)
                                        .foregroundColor(Color(hex: Constants.sectionButtonImageColor))
                                }
                            }
                        }
                        .padding(.horizontal, 18.0)
                    }
                }
                
            }
            
            private struct ListView: View {
                @ObservedObject var viewModel: ProductsViewModel
                @Binding var path: NavigationPath
                @Binding var canShowAlert: Bool
                @Binding var isShowingAlert: Bool
                let sectionId: UUID
                
                var body: some View {
                    ScrollView(.vertical, showsIndicators: false) {
                        if let section = viewModel.section(withId: sectionId) {
                            VStack(spacing: 6.0) {
                                ForEach(section.products, id: \.id) { product in
                                    CellView(product: product, onLikeToggle: {
                                        viewModel.updateStorageProductStatus(product, newState: .updated)
                                    })
                                    .background(
                                        Group {
                                            if product == section.products.last {
                                                GeometryReader { proxy in
                                                    Color.clear
                                                        .onChange(of: proxy.frame(in: .global)) { oldFrame, newFrame in
                                                            let screenHeight = UIScreen.main.bounds.height
                                                            if newFrame.maxY <= screenHeight {
                                                                if viewModel.hasMoreData, !viewModel.isPagination {
                                                                    viewModel.loadNextPage()
                                                                } else if !viewModel.hasMoreData, !viewModel.isPagination {
                                                                    canShowAlert = true
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                                        isShowingAlert = true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                }
                                                .frame(height: 0.0)
                                            }
                                        }
                                    )
                                }
                                if viewModel.isPagination {
                                    ZStack {
                                        Color.white
                                        ProgressView().tint(Color(hex: Constants.searchBarPlaceholderColor))
                                    }
                                    .frame(
                                        width: 364.0,
                                        height: 88.0
                                    )
                                    .cornerRadius(Constants.favoriteCellCornerRadius)
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    private struct FilteredListView: View {
        @ObservedObject var viewModel: ProductsViewModel
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 6.0) {
                    ForEach(viewModel.searchResults, id: \.id) { product in
                        CellView(product: product, searchQuery: viewModel.searchQuery, onLikeToggle: {
                            viewModel.updateStorageProductStatus(product, newState: .updated)
                        })
                    }
                }
            }
        }
        
    }
    
    private struct AlertView: View {
        
        var body: some View {
            Text("No more data for loading")
                .font(.custom(GlobalConstants.regularFont, size: 18.0))
                .foregroundColor(.white)
                .frame(width: 250.0, height: 250.0)
                .background(Color.black.opacity(0.8).cornerRadius(10.0))
        }
        
    }
    
    // MARK: - Modifiers
    
    private struct ScreenBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(hex: GlobalConstants.backgroundColor))
        }
        
    }
    
    private struct SectionNavigationModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @ObservedObject var networMonitor: NetworkMonitor
        
        func body(content: Content) -> some View {
            content
                .navigationDestination(for: UUID.self) { id in
                    FilteredProductsView(viewModel: viewModel, sectionId: id)
                }
                .navigationDestination(for: String.self) { _ in
                    AddProductView(viewModel: viewModel, networMonitor: networMonitor)
                }
        }
    }
    
    private struct LoadViewModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var searchQuery: String
        
        func body(content: Content) -> some View {
            content
                .onChange(of: searchQuery) {
                    viewModel.searchQuery = searchQuery
                }
        }
    }
    
    private struct AlertViewModifier: ViewModifier {
        @Binding var isShowingAlert: Bool
        @Binding var canShowAlert: Bool
        
        func body(content: Content) -> some View {
            ZStack {
                content
                if canShowAlert, !isShowingAlert {
                    AlertView()
                }
            }
        }
    }
}


