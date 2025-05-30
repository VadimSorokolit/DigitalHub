//
//  AlertView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//
    
import SwiftUI

struct AlertView<Content: View>: View {
    @Binding var isLoading: Bool
    let message: String
    let content: () -> Content
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            content()
                .disabled(isLoading)
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 24.0) {
                    Text(message)
                        .foregroundColor(.black)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 20.0))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20.0) {
                        Button("NO") {
                            onCancel()
                            isLoading = false
                        }
                        .frame(width: 60.0, height: 30.0)
                        .background(Color(hex: GlobalConstants.discountLabelColor))
                        .foregroundColor(.white)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 20.0))
                        .cornerRadius(8.0)
                        
                        Button("YES") {
                            onConfirm()
                            isLoading = false
                        }
                        .frame(width: 60.0, height: 30.0)
                        .background(Color(hex: GlobalConstants.priceLabelColor))
                        .foregroundColor(.white)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 20.0))
                        .cornerRadius(8.0)
                    }
                }
                .padding(28.0)
                .background(Color(.systemBackground))
                .cornerRadius(12.0)
                .shadow(radius: 12.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
}


