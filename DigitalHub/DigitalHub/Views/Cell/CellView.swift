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
    let onLikeToggle: () -> Void
    
    // MARK: - Main body
    
    var body: some View {
        HStack(spacing: 16.0) {
            ImageView(product: product)
            
            VStack(alignment: .leading, spacing: 8.0) {
                TitleWithLike(product: product, onLikeToggle: onLikeToggle)
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
        let onLikeToggle: () -> Void
        
        var body: some View {
            HStack {
                Text(product.name)
                    .font(.custom(GlobalConstants.semiBoldFont, size: 16.0))
                    .foregroundColor(Color(hex: "1F2937"))
                    .lineLimit(3)
                
                Spacer()
                
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


