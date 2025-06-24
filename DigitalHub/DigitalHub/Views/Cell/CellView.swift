//
//  CellView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 26.05.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct CellView: View {
    
    // MARK: - Objects
    
    private struct Constants {
        static let cellImageWidth: CGFloat = 64.0
    }
    
    // MARK: - Properties
    
    let product: StorageProduct
    let searchQuery: String?
    let onLikeToggle: () -> Void
    
    // MARK: - Initializer
    
    init(product: StorageProduct, searchQuery: String? = nil, onLikeToggle: @escaping () -> Void) {
        self.product = product
        self.searchQuery = searchQuery
        self.onLikeToggle = onLikeToggle
    }
    
    // MARK: - Main body
    
    var body: some View {
        HStack(spacing: 16.0) {
            ImageView(product: product)
            
            VStack(alignment: .leading, spacing: 8.0) {
                TitleWithLike(product: product, searchText: searchQuery, onLikeToggle: onLikeToggle)
                SubtitleWithPrice(product: product)
            }
        }
        .padding(12.0)
        .background(Color(hex: GlobalConstants.productCellColor))
        .cornerRadius(10.0)
        .padding(.horizontal, 18.0)
    }
    
    // MARK: - Subviews
    
    private struct ImageView: View {
        let product: StorageProduct
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color(hex: GlobalConstants.cellImagePlaceholderBackgroundColor))
                    .frame(width: Constants.cellImageWidth, height: Constants.cellImageWidth)
                    .cornerRadius(8.0)
                
                Group {
                    if let urlString = product.imageURL, !urlString.isEmpty, let url = URL(string: urlString) {
                        WebImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: Constants.cellImageWidth, height: Constants.cellImageWidth)
                        .clipped()
                        .cornerRadius(8.0)
                    }  else {
                        Image(systemName: GlobalConstants.placeholderImageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: Constants.cellImageWidth / 2.0, height: Constants.cellImageWidth / 2.0)
                    }
                }
            }
        }
        
    }
    
    private struct TitleWithLike: View {
        let product: StorageProduct
        let searchText: String?
        let onLikeToggle: () -> Void
        
        var body: some View {
            HStack {
                TitleHighlighted(productName: product.name, searchText: searchText)
                
                Spacer()
                
                LikeButtonWithImage(product: product, onLikeToggle: onLikeToggle)
            }
        }
        
        private struct TitleHighlighted: View {
            let productName: String
            let searchText: String?
            
            var body: some View {
                let query = searchText?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased() ?? ""
                
                let lowercasedName = productName.lowercased()
                
                if query.count > 2, let range = lowercasedName.range(of: query) {
                    let start = productName.distance(from: productName.startIndex, to: range.lowerBound)
                    let matchLength = query.count
                    
                    let prefix = String(productName.prefix(start))
                    let match = String(productName.dropFirst(start).prefix(matchLength))
                    let suffix = String(productName.dropFirst(start + matchLength))
                    
                    HStack(spacing: 0.0) {
                        styledText(prefix, highlight: false)
                        styledText(match, highlight: true)
                        styledText(suffix, highlight: false)
                    }
                } else {
                    styledText(productName)
                }
            }
            
            private func styledText(_ text: String, highlight: Bool = false) -> some View {
                Text(text)
                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                    .foregroundColor(Color(hex: 0x1F2937))
                    .background(highlight ? Color(hex: 0xFCFAA6) : .clear)
                    .lineLimit(3)
            }
        }
        
        private struct LikeButtonWithImage: View {
            let product: StorageProduct
            let onLikeToggle: () -> Void
            
            var body: some View {
                Button(action: {
                    onLikeToggle()
                }) {
                    Image(product.isFavorite ? GlobalConstants.fillHeartImageName : GlobalConstants.emptyHeartImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.0, height: 20.0)
                }
            }
            
        }
        
    }
    
    private struct SubtitleWithPrice: View {
        let product: StorageProduct
        
        var body: some View {
            HStack(alignment: .top) {
                Text(product.brandName ?? "")
                    .font(.custom(GlobalConstants.regularFont, size: 10.0))
                    .foregroundColor(Color(hex: 0x6B7280))
                    .lineLimit(3)
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.priceLabelColor))
                        .frame(width: 88.0, height: 28.0)
                        .cornerRadius(8.0)
                        .overlay(
                            Text(product.price ?? "--")
                                .font(.custom(GlobalConstants.semiBoldFont, size: 12.0))
                                .foregroundColor(.white)
                        )
                    
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.discountLabelColor))
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
            }
        }
        
    }
    
}



