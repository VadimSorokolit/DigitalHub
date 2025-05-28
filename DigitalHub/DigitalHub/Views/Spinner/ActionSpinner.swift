//
//  ActionSpinner.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//
    
import SwiftUI

struct ActionSpinner<Content: View>: View {
    @Binding var isPresented: Bool
    let message: String
    let content: () -> Content
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            content()
                .disabled(isPresented)
            
            if isPresented {
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
                            isPresented = false
                        }
                        .frame(width: 80.0, height: 40.0)
                        .background(Color(hex: GlobalConstants.discountLabelColor))
                        .foregroundColor(.white)
                        .font(.custom(GlobalConstants.semiBoldFont, size: 20.0))
                        .cornerRadius(8.0)
                        
                        Button("YES") {
                            onConfirm()
                            isPresented = false
                        }
                        .frame(width: 80.0, height: 40.0)
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


