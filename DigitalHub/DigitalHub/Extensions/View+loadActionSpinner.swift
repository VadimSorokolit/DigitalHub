//
//  View+loadActionSpinner.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 28.05.2025.
//

import SwiftUI

extension View {
    
    func loadActionSpinner(
        isPresented: Binding<Bool>,
        message: String = "",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        ActionSpinner(
            isPresented: isPresented,
            message: message,
            content: { self },
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }
    
}
