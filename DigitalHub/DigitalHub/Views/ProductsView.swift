//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI

struct ProductsView: View {
    
    private struct Constants {
        static let headerTitleName: String = "Products"
        static let headerImageName: String = "headerImage"
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
        static let favoriteImageWidth: CGFloat = 128.0
    }
    
    @StateObject private var viewModel: ProductsViewModel = ProductsViewModel(apiClient: MoyaClient())
    @State private var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 28.0) {
                HeaderView()
                ProductListView(viewModel: viewModel, path: $path)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(hex: GlobalConstants.backgroundColor))
            .navigationDestination(for: Section.SectionType.self) { sectionType in
                switch sectionType {
                    case .favorite :
                        FilteredProductsView(viewModel: viewModel, sectionType: sectionType)
                        
                    case .unfavorite:
                        FilteredProductsView(viewModel: viewModel, sectionType: sectionType)
                }
            }
        }
        .onAppear {
            viewModel.loadFirstPage()
        }
        .loadRequestSpinner(isLoading: viewModel.isLoading)
    }
    
    private struct HeaderView: View {
        
        var body: some View {
            VStack(spacing: 18.0) {
                TitleView()
                SearchBarView()
            }
            .padding(.top, 34.0)
            .padding(.horizontal, 18.0)
        }
        
        private struct TitleView: View {
            
            var body: some View {
                ZStack {
                    TitleWithImage()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // TODO: - Implement navigation to "Add Product" screen
                            print("Button tapped")
                        }) {
                            Image(Constants.headerButtonImageName)
                                .resizable()
                                .frame(width: Constants.headerTitleImageSize, height: Constants.headerTitleImageSize)
                                .scaledToFit()
                                .opacity(0.8)
                        }
                    }
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
                                .opacity(0.8)
                                .offset(x: -50.0),
                            alignment: .leading
                        )
                }
                
            }
            
        }
        
        private struct SearchBarView: View {
            @State private var searchText: String = ""
            
            var body: some View {
                HStack {
                    Image(systemName: Constants.searchBarImageName)
                        .foregroundColor(Color(hex: Constants.searchBarImageColor))
                        .padding(.leading, 11.0)
                    
                    TextField(Constants.searchBarPlaceholder, text: $searchText)
                        .font(.custom(GlobalConstants.regularFont, size: 12.0))
                        .foregroundColor(Color(hex: Constants.searchBarPlaceholderColor))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.leading, 7.0)
                }
                .frame(height: 36.0)
                .background(Color(hex: Constants.searchBarColor))
                .cornerRadius(11.0)
            }
            
        }
        
    }
    
    private struct ProductListView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var path: NavigationPath
        
        var body: some View {
            VStack(spacing: Constants.productsListInterSectionSpacing) {
                ForEach(viewModel.sections, id: \.id) { section in
                    if section.type == .favorite, !section.products.isEmpty {
                        SectionFavorites(viewModel: viewModel, path: $path, section: section)
                    }
                    if section.type == .unfavorite, !section.products.isEmpty {
                        SectionUnfavorites(viewModel: viewModel, path: $path, section: section)
                    }
                }
            }
            
        }

        private struct SectionFavorites: View {
            @ObservedObject var viewModel: ProductsViewModel
            @Binding var path: NavigationPath
            let section: Section
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16.0) {
                    HeaderView(path: $path, section: section)
                    ListView(viewModel: viewModel, products: section.products)
                }
            }
            
            private struct HeaderView: View {
                @Binding var path: NavigationPath
                let section: Section
                
                var body: some View {
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
                            path.append(Section.SectionType.favorite)
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
            
            private struct ListView: View {
                @ObservedObject var viewModel: ProductsViewModel
                let products: [Product]
                
                var body: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12.0) {
                            ForEach(products, id: \.id) { product in
                                FavoriteCellView(viewModel: viewModel, product: product)
                            }
                        }
                        .padding(.leading, 18.0)
                    }
                }
                
                private struct FavoriteCellView: View {
                    @ObservedObject var viewModel: ProductsViewModel
                    let product: Product
                    
                    var body: some View {
                        VStack(spacing: 11.0) {
                            ImageView(product: product)
                            
                            VStack(alignment: .leading, spacing: 7.0) {
                                InfoView(product: product)
                                PriceView(viewModel: viewModel, product: product)
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
                                    Image(systemName: GlobalConstants.systemImageName)
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 128.0, height: 100.0)
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
                            .frame(width: Constants.favoriteImageWidth, alignment: .leading)
                        }
                        
                    }
                    
                    private struct PriceView: View {
                        @ObservedObject var viewModel: ProductsViewModel
                        let product: Product
                        
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
                                    self.viewModel.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
                                }) { Image(GlobalConstants.redHeartImageName)
                                        .resizable()
                                        .frame(width: 20.0, height: 20.0)
                                }
                            }
                            .frame(width: Constants.favoriteImageWidth)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    private struct SectionUnfavorites: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var path: NavigationPath
        let section: Section

        var body: some View {
            VStack(alignment: .leading, spacing: 16.0) {
                HeaderView(path: $path, section: section)
                ListView(viewModel: viewModel, products: section.products)
            }
        }
        
        private struct HeaderView: View {
            @Binding var path: NavigationPath
            let section: Section
            
            var body: some View {
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
                        path.append(Section.SectionType.unfavorite)
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
        
        private struct ListView: View {
            @ObservedObject var viewModel: ProductsViewModel
            let products: [Product]
            
            var body: some View {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6.0) {
                        ForEach(products, id: \.id) { product in
                            CellView(viewModel: viewModel, product: product, isFavorite: product.isFavorite)
                        }
                    }
                }
            }
                        
        }
        
    }
    
}

#Preview {
    ProductsView()
}
