//
//  View+loadAlert.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 28.05.2025.
//

import SwiftUI

extension View {
    
    func loadAlert(
        isShow: Binding<Bool>,
        message: String = "",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        AlertView(
            isLoading: isShow,
            message: message,
            content: { self },
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }
    
}
