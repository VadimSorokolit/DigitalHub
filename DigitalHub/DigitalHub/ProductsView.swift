//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import SwiftUI
import SwiftData

struct ProductsView: View {
    @StateObject private var viewModel = ProductsViewModel(apiClient: MoyaClient())
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                    if !section.items.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4.0) {
                                    Text(section.title)
                                        .font(.title3)
                                    Text(section.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 17)

                                Spacer()

                                Button(action: {}) {
                                    HStack(spacing: 6.0) {
                                        Text(viewModel.constants.button.title)
                                        Image(systemName: viewModel.constants.button.imageName)
                                    }
                                    .font(.subheadline)
                                }
                                .padding(.trailing, 17)
                            }
                            VStack(alignment: .leading) {
                                Text("Hello")
                                    .padding()
                            }
                            .frame(
                                width: index == 0 ? 220 : 360,
                                height: index == 0 ? 191: 116
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 16).fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "EB4132"), lineWidth: 3)
                            )
                            .listRowSeparator(.hidden)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            self.viewModel.loadFirstPage()
        }
    }
}

#Preview {
    ProductsView()
}
