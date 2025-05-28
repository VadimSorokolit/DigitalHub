//
//  DefaultSpinner.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//
    
import SwiftUI

struct Spinner<Content: View>: View {
    let isLoading: Bool
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
                .disabled(isLoading)
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView()
                    .tint(.accentColor)
                    .scaleEffect(2.0)
                    .frame(width: 40.0, height: 40.0)
            }
        }
    }
    
}


