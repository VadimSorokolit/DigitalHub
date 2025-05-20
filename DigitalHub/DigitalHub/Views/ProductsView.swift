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
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
            }
            .background(Color(hex: Constants.backgroundColor))
        }
    }
    
    struct HeaderView: View {
        var body: some View {
            VStack {
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
                    .padding(.top, 18.0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
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
            .frame(width: .infinity, height: 36.0)
            .background(Color(hex: Constants.searchBarColor))
            .cornerRadius(11.0)
        }
    }
    
    struct ProductListView: View {
        @StateObject private var viewModel = ProductsViewModel(apiClient: MoyaClient())
        var body: some View {}
    }
    
}

#Preview {
    ProductsView()
}
