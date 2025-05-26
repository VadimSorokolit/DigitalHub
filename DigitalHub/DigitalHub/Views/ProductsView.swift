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
        static let systemImageName: String = "photo"
        static let headerButtonImageName: String = "headerButtonImage"
        static let searchBarImageName: String = "magnifyingglass"
        static let searchBarPlaceholder: String = "Search"
        static let headerTitleFontColor: String = "1F2937"
        static let searchBarImageColor: String = "9CA3AF"
        static let searchBarPlaceholderColor: String = "9CA3AF"
        static let searchBarColor: String = "E6E7E9"
        static let backgroundColor: String = "F6F6F6"
        static let sectionTitleColor: String = "1F2937"
        static let sectionSubtitleColor: String = "6B7280"
        static let sectionButtonTitleColor: String = "6B7280"
        static let sectionButtonImageColor: String = "89909E"
        static let discountLabelColor: String = "EB4132"
        static let priceLabelColor: String = "32B768"
        static let priceValueColor: String = "FFFFFF"
        static let discountValueColor: String = "FFFFFF"
        static let redHeartImageName: String = "redHeart"
        static let productCellColor: String = "FFFFFF"
        static let textLineCount: Int = 3
        static let headerTitleImageSize: CGFloat = 30.0
        static let headerTitleFontSize: CGFloat = 20.0
        static let productsListInterSectionSpacing: CGFloat = 36.0
        static let productsHeaderTextSpacing: CGFloat = 4.0
        static let favoriteImageWidth: CGFloat = 128.0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28.0) {
                HeaderView()
                ProductListView()
            }
            .background(Color(hex: Constants.backgroundColor))
        }
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
        @StateObject private var viewModel = ProductsViewModel(apiClient: MoyaClient())
        
        var body: some View {
            VStack(spacing: Constants.productsListInterSectionSpacing) {
                ForEach(viewModel.sections, id: \.id) { section in
                    if section.type == .favorite, !section.products.isEmpty {
                        SectionFavorites(section: section)
                    }
                    if section.type == .unfavorite, !section.products.isEmpty {
                        SectionUnfavorites(section: section)
                    }
                }
            }
            .onAppear {
                viewModel.getMockData()
            }
        }
        
        private struct SectionFavorites: View {
            let section: Section
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16.0) {
                    HeaderView(section: section)
                    FavoriteListView(products: section.products)
                }
            }
            
            private struct HeaderView: View {
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
                            // TODO: - Go to "Favorites list" screen
                            print("Button tapped")
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
            
            private struct FavoriteListView: View {
                let products: [Product]
                
                var body: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12.0) {
                            ForEach(products, id: \.id) { product in
                                FavoriteCellView(product: product)
                            }
                        }
                        .padding(.leading, 18.0)
                    }
                }
                
                private struct FavoriteCellView: View {
                    let product: Product
                    
                    var body: some View {
                        VStack(spacing: 11.0) {
                            ImageView(product: product)
                            
                            VStack(alignment: .leading, spacing: 7.0) {
                                InfoView(product: product)
                                PriceView(product: product)
                            }
                        }
                        .padding([.top, .bottom, .horizontal], 10.0)
                        .background(Color(hex: Constants.productCellColor))
                        .cornerRadius(16.0)
                    }
                    
                    struct ImageView: View {
                        let product: Product
                        
                        var body: some View {
                            Group {
                                if let productImage = product.imageURL, !productImage.isEmpty, UIImage(named: productImage) != nil {
                                    Image(productImage)
                                        .resizable()
                                } else {
                                    Image(systemName: Constants.systemImageName)
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
                        let product: Product
                        
                        var body: some View {
                            HStack {
                                ZStack(alignment: .topTrailing) {
                                    Rectangle()
                                        .fill(Color(hex: Constants.priceLabelColor))
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
                                        .fill(Color(hex: Constants.discountLabelColor))
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
                                
                                Image(Constants.redHeartImageName)
                                    .resizable()
                                    .frame(width: 20.0, height: 20.0)
                            }
                            .frame(width: Constants.favoriteImageWidth)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    private struct SectionUnfavorites: View {
        let section: Section
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16.0) {
                HeaderView(section: section)
                UnfavoriteListView(products: section.products)
            }
        }
        
        private struct HeaderView: View {
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
                        // TODO: - Go to "Unfavorites list" screen
                        print("Button tapped")
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
        
        private struct UnfavoriteListView: View {
            let products: [Product]
            
            var body: some View {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6.0) {
                        ForEach(products, id: \.id) { product in
                            UnfavoriteCellView(product: product)
                        }
                    }
                }
            }
            
            private struct UnfavoriteCellView: View {
                let product: Product
                
                var body: some View {
                    HStack(spacing: 16.0) {
                        ImageView(product: product)
                        
                        VStack(alignment: .leading, spacing: 8.0) {
                            TitleWithLike(product: product)
                            SubtitleWithPrice(product: product)
                        }
                    }
                    .padding([.top, .bottom, .horizontal], 12.0)
                    .background(.white)
                    .cornerRadius(10.0)
                    .padding(.horizontal, 18.0)
                }
                
                private struct ImageView: View {
                    let product: Product
                    
                    var body: some View {
                        Group {
                            if let productImage = product.imageURL, !productImage.isEmpty, UIImage(named: productImage) != nil {
                                Image(productImage)
                                    .resizable()
                            } else {
                                Image(systemName: Constants.systemImageName)
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64.0, height: 64.0)
                        .cornerRadius(8.0)
                    }
                    
                }
                
                private struct TitleWithLike: View {
                    let product: Product
                    
                    var body: some View {
                        HStack(alignment: .top) {
                            Text(product.name)
                                .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                                .foregroundColor(Color(hex: "1F2937"))
                                .frame(width: 195.0, alignment: .leading)
                                .padding(.top, 8.0)
                                .lineLimit(Constants.textLineCount)
                            
                            Spacer()
                            
                            Image(Constants.redHeartImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20.0, height: 21.0)
                        }
                    }
                    
                }
                
                private struct SubtitleWithPrice: View {
                    let product: Product
                    
                    var body: some View {
                        HStack(alignment: .top) {
                            Text(product.brandName ?? "")
                                .font(.custom(GlobalConstants.regularFont, size: 10.0))
                                .foregroundColor(Color(hex: "6B7280"))
                                .frame(width: 117.0, alignment: .leading)
                                .lineLimit(Constants.textLineCount)
                            
                            Spacer()
                            
                            ZStack(alignment: .topTrailing) {
                                Rectangle()
                                    .fill(Color(Color(hex: Constants.priceLabelColor)))
                                    .frame(width: 88.0, height: 28.0)
                                    .cornerRadius(8.0)
                                    .overlay(
                                        Text(product.price ?? "--")
                                            .font(.custom(GlobalConstants.semiBoldFont, size: 12.0))
                                            .foregroundColor(.white)
                                    )
                                
                                Rectangle()
                                    .fill(Color(hex: Constants.discountLabelColor))
                                    .frame(width: 23.0, height: 9.0)
                                    .cornerRadius(3.0)
                                    .overlay(
                                        Text(product.discount ?? "--")
                                            .font(.custom(GlobalConstants.semiBoldFont, size: 6.0))
                                            .foregroundColor(.white),
                                        alignment: .center
                                    )
                                    .offset(x: 4.0, y: -4.0)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
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
