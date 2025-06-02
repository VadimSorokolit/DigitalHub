//
//  CellView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 26.05.2025.
//

import SwiftUI

struct CellView: View {
    
    // MARK: - Properties
    
    let product: Product
    let searchQuery: String?
    let onLikeToggle: () -> Void
    
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
        .background(Color.white)
        .cornerRadius(10.0)
        .padding(.horizontal, 18.0)
    }
    
    // MARK: - Subviews
    
    private struct ImageView: View {
        let product: Product
        
        var body: some View {
            Group {
                if let url = product.imageURL,
                   !url.isEmpty,
                   UIImage(named: url) != nil {
                    Image(url).resizable()
                } else {
                    Image(systemName: GlobalConstants.systemImageName)
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
        let searchText: String?
        let onLikeToggle: () -> Void
        
        var body: some View {
            HStack {
                TitleWithlight(productName: product.name, searchText: searchText)
                
                Spacer()
                
                LikeButtonWithImage(product: product, onLikeToggle: onLikeToggle)
            }
        }
        
        private struct TitleWithlight: View {
            let productName: String
            let searchText: String?
            
            var body: some View {
                let query = searchText?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased() ?? ""
                
                if query.count < 3 || productName.lowercased().range(of: query) == nil {
                    return AnyView(
                        Text(productName)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                            .lineLimit(3)
                    )
                }
                let lowercasedName = productName.lowercased()
                guard let range = lowercasedName.range(of: query) else {
                    return AnyView(
                        Text(productName)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                            .lineLimit(3)
                    )
                }
                let startIndex = productName.distance(from: productName.startIndex,
                                                      to: range.lowerBound)
                let matchLength = query.count
                
                let prefix = String(productName.prefix(startIndex))
                let match  = String(productName.dropFirst(startIndex).prefix(matchLength))
                let suffix = String(productName.dropFirst(startIndex + matchLength))
                
                return AnyView(
                    HStack(spacing: 0) {
                        Text(prefix)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                        
                        Text(match)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                            .background(Color(hex: "FCFAA6"))
                        
                        Text(suffix)
                            .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                            .foregroundColor(Color(hex: "1F2937"))
                    }
                        .lineLimit(3)
                )
            }
            
        }
        
        private struct LikeButtonWithImage: View {
            let product: Product
            let onLikeToggle: () -> Void
            
            var body: some View {
                Button(action: {
                    onLikeToggle()
                }) {
                    Image(
                        product.isFavorite
                        ? GlobalConstants.redHeartImageName
                        : GlobalConstants.grayHeartName
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.0, height: 20.0)
                }
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


