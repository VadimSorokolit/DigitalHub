//
//  View+loadSpinner.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.05.2025.
//

import SwiftUI

extension View {
    
    func loadRequestSpinner(isLoading: Bool) -> some View {
        Spinner(isLoading: isLoading) { self }
    }
    
}

