//
//  SpinnerView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//
    
import SwiftUI

struct SpinnerView : View {
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .tint(.white)
                .scaleEffect(2.0)
                .frame(width: 40.0, height: 40.0)
        }
    }
    
}
    



