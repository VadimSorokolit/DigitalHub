//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI
import SwiftData

struct ProductsView: View {
    
    private struct Constants {
        static let headerTitleName: String = "Products"
        static let headerTitleFontColor: String = "1F2937"
        static let headerTitleFontSize: CGFloat = 20.0
        static let headerImageName: String = "headerImage"
        static let headerButtonImageName: String = "headerButtonImage"
        static let searchBarImageName: String = "magnifyingglass"
        static let searchBarPlaceholder: String = "Search"
        static let searchBarImageColor: String = "9CA3AF"
        static let searchBarPlaceholderColor: String = "9CA3AF"
        static let searchBarColor: String = "E6E7E9"
        static let favoriteSectionTitle: String = "Favorites"
        static let unfavotieSectionTitle: String = "Unfavorites"
        static let backgroundColor: String = "F6F6F6"
        static let productsListInterSectionSpacing: CGFloat = 36.0
        static let productsHeaderTextSpacing: CGFloat = 4.0
        static let sectionTitleColor: String = "1F2937"
        static let sectionSubtitleColor: String = "6B7280"
        static let sectionButtonTitleColor: String = "6B7280"
        static let sectionButtonImageColor: String = "89909E"
        static let discountLabelColor: String = "EB4132"
        static let priceLabelColor: String = "32B768"
        static let priceValueColor: String = "FFFFFF"
        static let discountValueColor: String = "FFFFFF"
        static let redHeartImageName: String = "redHeart"
        static let favoriteImageWidth: CGFloat = 128.0
        static let productCellColor: String = "FFFFFF"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28.0) {
                HeaderView()
                ProductListView()
            }
//          .background(Color(hex: Constants.backgroundColor))
            .background(.brown)
        }
    }
    
    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 18.0) {
                ZStack {
                    Text(Constants.headerTitleName)
                        .font(.custom(GlobalConstants.semiBoldFont, size: Constants.headerTitleFontSize))
                        .foregroundColor(Color(hex: Constants.headerTitleFontColor))
                        .overlay(
                            Image(Constants.headerImageName)
                                .resizable()
                                .frame(width: 30.0, height: 30.0)
                                .scaledToFit()
                                .opacity(0.8)
                                .offset(x: -50.0),
                            alignment: .leading
                        )
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Tapped")
                        }) {
                            Image(Constants.headerButtonImageName)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .scaledToFit()
                                .opacity(0.8)
                        }
                    }
                }
                SearchBarView()
            }
            .padding(.top, 34.0)
            .padding(.horizontal, 18.0)
        }
    }
    
    struct SearchBarView: View {
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
            .background(.blue)
        }
    }
    
    struct SectionHeaderView: View {
        let section: Section
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Constants.productsHeaderTextSpacing) {
                    Text(section.title)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                        .foregroundColor(Color(hex:Constants.sectionTitleColor))
                    Text(section.subtitle)
                        .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                        .foregroundColor(Color(hex:Constants.sectionSubtitleColor))
                }
                Spacer()
                
                Button(action: {
                }) {
                    HStack(spacing: 6.0) {
                        Text(section.buttonTitle)
                            .font(.custom(GlobalConstants.mediumFont, size: 12.0))
                            .foregroundColor(Color(hex:Constants.sectionButtonTitleColor))
                        Image(systemName: section.buttonImageName)
                            .resizable()
                            .frame(width: 5.0, height: 8.75)
                            .foregroundColor(Color(hex:Constants.sectionButtonImageColor))
                    }
                }
            }
        }
    }
    
    struct SectionFavorites: View {
        let section: Section
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16.0) {
                SectionHeaderView(section: section)
                    .background(.yellow)
                    .padding(.horizontal, 18.0)
                ProductCellView(items: section.items)
                    .padding(.leading, 18)
            }
        }
        
        struct ProductCellView: View {
            let items: [Product]
            
            struct ProductImage: View {
                var body: some View {
                    Image("testImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128.0, height: 100.0, alignment: .top)
                        .clipped()
                        .cornerRadius(8.0, corners: [.topLeft, .topRight])
                }
            }
                
            struct ProductInfo: View {
                let item: Product
                
                var body: some View {
                    VStack(spacing: 4.0) {
                        Text(item.productName)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                        
                        Text(item.brandName ?? "")
                            .font(.custom(GlobalConstants.regularFont, size: 10.0))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: Constants.favoriteImageWidth, alignment: .leading)
                }
            }
                
            struct ProductPrice: View {
                let item: Product
                
                var body: some View {
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            Rectangle()
                                .fill(Color(hex: Constants.priceLabelColor))
                                .frame(width: 50.0, height: 20.0)
                                .cornerRadius(3.0, corners: [.topLeft, .topRight, .bottomRight])
                                .cornerRadius(10.0, corners: [.bottomLeft])
                                .overlay(
                                    Text(item.price ?? "")
                                        .font(.custom(GlobalConstants.semiBoldFont, size: 8.0))
                                        .foregroundColor(Color(hex: Constants.priceValueColor)),
                                    alignment: .center
                                )
                            Rectangle()
                                .fill(Color(hex: Constants.discountLabelColor))
                                .frame(width: 23.0, height: 9.0)
                                .cornerRadius(3.0)
                                .overlay(
                                    Text(item.discount ?? "")
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
            
            var body: some View {
                let cornerRadius: CGFloat = 16.0
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12.0) {
                        ForEach(items, id: \.id) { item in
                            VStack(spacing: 11.0) {
                               ProductImage()
                                VStack(alignment: .leading, spacing: 7.0) {
                                    ProductInfo(item: item)
                                    ProductPrice(item: item)
                                }
                            }
                            .padding([.top, .bottom, .horizontal], 10)
                            .background(Color(hex: Constants.productCellColor))
                            .cornerRadius(cornerRadius)
                        }
                    }
                }

            }
        }
    }
    
    struct SectionUnfavorites: View {
        let section: Section
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6.0) {
                SectionHeaderView(section: section)
                    .background(.yellow)
                ProductCellView(items: section.items)
            }
            .background(.red)
            .padding(.horizontal, 18.0)
        }
        
        struct ProductCellView: View {
            let items: [Product]
            
            struct ProductImage: View {
                var body: some View {
                    Image("testImage")
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 64.0, height: 64.0)
                        .cornerRadius(8.0)
                }
            }
            
            struct ProductInfoWithLike: View {
                let item: Product
                
                var body: some View {
                    HStack(alignment: .top) {
                        Text(item.productName)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                            .frame(width: 195.0, alignment: .leading)
                            .padding(.top, 8.0)
                        Spacer()
                        Image(Constants.redHeartImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20.0, height: 21.0)
                    }
                }
            }
            
            struct ProductInfoWithPrice: View {
                let item: Product
                
                var body: some View {
                    HStack(alignment: .top) {
                        Text(item.brandName ?? "")
                            .font(.custom(GlobalConstants.regularFont, size: 10.0))
                            .foregroundColor(Color(hex: "6B7280"))
                            .frame(width: 117.0, alignment: .leading)
                        Spacer()
                        ZStack(alignment: .topTrailing) {
                            Rectangle()
                                .fill(Color(Color(hex: Constants.priceLabelColor)))
                                .frame(width: 88.0, height: 28.0)
                                .cornerRadius(8.0)
                                .overlay(
                                    Text(item.price ?? "")
                                        .font(.custom(GlobalConstants.semiBoldFont, size: 12.0))
                                        .foregroundColor(.white)
                                )
                            Rectangle()
                                .fill(Color(hex: Constants.discountLabelColor))
                                .frame(width: 23.0, height: 9.0)
                                .cornerRadius(3.0)
                                .overlay(
                                    Text(item.discount ?? "")
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
            
            var body: some View {
                let cornerRadius: CGFloat = 10.0
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 6.0) {
                        ForEach(items, id: \.id) { item in
                            HStack(alignment: .center, spacing: 16.0) {
                                ProductImage()
                                HStack {
                                    VStack(alignment: .leading, spacing: 8.0) {
                                        ProductInfoWithLike(item: item)
                                        ProductInfoWithPrice(item: item)
                                    }
                                }
                            }
                            .padding([.top, .bottom, .horizontal], 12)
                            .background(.white)
                            .cornerRadius(cornerRadius)
                        }
                    }
                }
            }
            
        }
        
    }
    
    struct ProductListView: View {
        @StateObject private var viewModel = ProductsViewModel(apiClient: MoyaClient())
        
        var body: some View {
            VStack(spacing: 36.0) {
                ForEach(self.viewModel.sections, id: \.id) { section in
                    if section.type == .favorite, !section.items.isEmpty {
                        SectionFavorites(section: section)
                    }
                    if section.type == .unfavorite, !section.items.isEmpty {
                        SectionUnfavorites(section: section)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear {
                self.viewModel.getMokeData()
            }
        }
    }
    
}

#Preview {
    ProductsView()
}


