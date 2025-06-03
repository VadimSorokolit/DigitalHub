//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI

struct ProductsView: View {
    
    // MARK: - Objects
    
    private struct Constants {
        static let headerTitleName: String = "Products"
        static let headerImageName: String = "headerImage"
        static let cancelButtonImageName: String = "xmark.circle.fill"
        static let headerButtonImageName: String = "headerButtonImage"
        static let searchBarImageName: String = "magnifyingglass"
        static let searchBarPlaceholder: String = "Search"
        static let headerTitleFontColor: String = "1F2937"
        static let searchBarImageColor: String = "9CA3AF"
        static let searchBarPlaceholderColor: String = "9CA3AF"
        static let searchBarColor: String = "E6E7E9"
        static let sectionTitleColor: String = "1F2937"
        static let sectionSubtitleColor: String = "6B7280"
        static let sectionButtonTitleColor: String = "6B7280"
        static let sectionButtonImageColor: String = "89909E"
        static let priceValueColor: String = "FFFFFF"
        static let discountValueColor: String = "FFFFFF"
        static let productCellColor: String = "FFFFFF"
        static let textLineCount: Int = 3
        static let headerTitleImageSize: CGFloat = 30.0
        static let headerTitleFontSize: CGFloat = 20.0
        static let productsListInterSectionSpacing: CGFloat = 36.0
        static let productsHeaderTextSpacing: CGFloat = 4.0
        static let favoriteProductImageWidth: CGFloat = 128.0
        static let favoriteProductImageHeight: CGFloat = 100.0
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @State private var path: NavigationPath = NavigationPath()
    @State private var searchQuery: String = ""
    
    // MARK: - Main body
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 28.0) {
                HeaderView(searchQuery: $searchQuery)
                if searchQuery.isEmpty {
                    ProductsListView(viewModel: viewModel, path: $path)
                } else {
                    FilteredListView(viewModel: viewModel)
                }
            }
            .modifier(ScreenBackgroundModifier())
            .modifier(SectionNavigationModifier(viewModel: viewModel))
            .modifier(LoadViewModifire(viewModel: viewModel, searchQuery: $searchQuery))
        }
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        @Binding var searchQuery: String
        
        var body: some View {
            VStack(spacing: 18.0) {
                TitleView()
                SearchBarView(searchQuery: $searchQuery)
            }
            .padding(.top, 34.0)
            .padding(.horizontal, 18.0)
        }
        
        private struct TitleView: View {
            
            var body: some View {
                ZStack {
                    TitleWithImage()
                    ImageButton()
                }
            }
            
            private struct TitleWithImage: View {
                
                var body: some View {
                    Text(Constants.headerTitleName)
                        .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerTitleFontSize))
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
                
                var body: some View {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // TODO: - Implement navigation to "Add Product" screen
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
                                .foregroundColor(Color(hex: "737475"))
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
        
        var body: some View {
            VStack(spacing: Constants.productsListInterSectionSpacing) {
                ForEach(viewModel.sections, id: \.id) { section in
                    if section.type == .favorite, !section.products.isEmpty {
                        SectionFavorites(viewModel: viewModel, path: $path, sectionId: section.id)
                    }
                    if section.type == .unfavorite, !section.products.isEmpty {
                        SectionUnfavorites(viewModel: viewModel, path: $path, sectionId: section.id)
                    }
                }
            }
        }
        
        private struct SectionFavorites: View {
            @ObservedObject var viewModel: ProductsViewModel
            @Binding var path: NavigationPath
            let sectionId: UUID
            
            var body: some View {
                if let section = viewModel.section(withId: sectionId) {
                    VStack(alignment: .leading, spacing: 16.0) {
                        HeaderView(viewModel: viewModel, path: $path, sectionId: sectionId)
                        ListView(viewModel: viewModel, sectionId: section.id)
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
                let sectionId: UUID
                
                var body: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        if let section = viewModel.section(withId: sectionId) {
                            HStack(alignment: .top,  spacing: 12.0) {
                                ForEach(section.products, id: \.id) { product in
                                    CellView(product: product, onLikeToogle: {
                                        viewModel.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
                                    })
                                }
                                Color.clear
                                    .frame(width: 6.0)
                            }
                            .padding(.leading, 18.0)
                        }
                    }
                }
                
                private struct CellView: View {
                    let product: Product
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
                        .background(Color(hex: Constants.productCellColor))
                        .cornerRadius(16.0)
                    }
                    
                    private struct ImageView: View {
                        let product: Product
                        
                        var body: some View {
                            Group {
                                if let productImage = product.imageURL, !productImage.isEmpty, UIImage(named: productImage) != nil {
                                    Image(productImage)
                                        .resizable()
                                } else {
                                    Rectangle()
                                        .fill(Color(hex: GlobalConstants.cellImagePlaceholderBackgroundColor))
                                        .overlay(
                                            Image(systemName: GlobalConstants.systemImageName)
                                                .resizable()
                                                .foregroundColor(.gray)
                                                .frame(width: Constants.favoriteProductImageWidth / 2.0, height: Constants.favoriteProductImageHeight / 2.0)
                                        )
                                }
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Constants.favoriteProductImageWidth, height: Constants.favoriteProductImageHeight)
                            .clipped()
                            .cornerRadius(8.0, corners: [.topLeft, .topRight])
                        }
                        
                    }
                    
                    private struct InfoView: View {
                        let product: Product
                        
                        var body: some View {
                            VStack(alignment: .leading, spacing: 4.0) {
                                Text(product.name)
                                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                    .foregroundColor(Color(hex: "1F2937"))
                                
                                Text(product.brandName ?? "")
                                    .font(.custom(GlobalConstants.regularFont, size: 10.0))
                                    .foregroundColor(Color(hex: "6B7280"))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(Constants.textLineCount)
                            .frame(width: Constants.favoriteProductImageWidth, alignment: .leading)
                        }
                        
                    }
                    
                    private struct PriceView: View {
                        let product: Product
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
                                }) { Image(GlobalConstants.redHeartImageName)
                                        .resizable()
                                        .frame(width: 20.0, height: 20.0)
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
            let sectionId: UUID
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16.0) {
                    HeaderView(viewModel: viewModel, path: $path, sectionId: sectionId)
                    ListView(viewModel: viewModel, sectionId: sectionId)
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
                let sectionId: UUID
                
                var body: some View {
                    ScrollView(.vertical, showsIndicators: false) {
                        if let section = viewModel.section(withId: sectionId) {
                            VStack(spacing: 6.0) {
                                ForEach(section.products, id: \.id) { product in
                                    CellView(product: product, onLikeToggle: {
                                        viewModel.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)})
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
                            viewModel.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
                        })
                    }
                }
            }
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
        
        func body(content: Content) -> some View {
            content
                .navigationDestination(for: UUID.self) { id in
                    FilteredProductsView(viewModel: viewModel, sectionId: id)
                }
        }
        
    }
    
    private struct LoadViewModifire: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var searchQuery: String
        
        func body(content: Content) -> some View {
            content
                .onChange(of: searchQuery) {
                    viewModel.searchQuery = searchQuery
                }
        }
    }
    
}

//#Preview {
//    let viewModel = ProductsViewModel(apiClient: MoyaClient())
//
//    ProductsView(viewModel: viewModel)
//}
