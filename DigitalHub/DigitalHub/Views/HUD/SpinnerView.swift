//
//  SpinnerView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//
    
import SwiftUI

struct SpinnerView: View {
    let tintColor: Color
    let backgroundColor: Color
    
    init(tintColor: Color = .white, backgroundColor: Color = Color.black.opacity(0.4)) {
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: tintColor)
                )
                .scaleEffect(2.0)
                .frame(width: 40.0, height: 40.0)
        }
    }
    
}
    



