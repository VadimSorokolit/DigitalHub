//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 26.05.2025.
//

import SwiftUI

struct FilteredProductsView: View {
    
    // MARK: – Constants
    
    private struct Constants {
        static let headerTitleName = "Products"
    }
    
    @ObservedObject var viewModel: ProductsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSelectedAll = false
    @State private var showSpinner = false
    
    var sectionType: Section.SectionType
    private var actionText: String {
        isSelectedAll ? "add all" : "remove all"
    }

    var body: some View {
        VStack(spacing: 25.0) {
            HeaderView(viewModel: viewModel, isSelectedAll: $isSelectedAll, showSpinner: $showSpinner, sectionType: sectionType)
            ListView(viewModel: viewModel, sectionType: sectionType)
        }
        .background(Color(hex: GlobalConstants.backgroundColor))
        .navigationBarBackButtonHidden(true)
        .loadActionSpinner(
            isPresented: $showSpinner,
            message: "Are you sure you want to \(actionText) ?",
            onConfirm: {
                for section in viewModel.sections {
                    if section.type == sectionType {
                        for product in section.products {
                            viewModel.updateProductStatus(
                                id: product.id,
                                isFavourite: isSelectedAll
                            )
                        }
                    }
                }
            },
            onCancel: {
                isSelectedAll.toggle()
            }
        )
        .onAppear {
            isSelectedAll = (sectionType == .favorite)
        }
    }
    
    private struct HeaderView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Environment(\.dismiss) private var dismiss
        @Binding var isSelectedAll: Bool
        @Binding var showSpinner: Bool
        
        let sectionType: Section.SectionType

        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    })
                    {
                        Image(GlobalConstants.backButtonImageName)
                            .frame(width: 26.0, height: 24.0)
                    }
                    Spacer()
                    
                    HStack(spacing: 6.0) {
                        Text(isSelectedAll ? "Remove" : "Add")
                            .font(.custom(GlobalConstants.semiBoldFont, size: 10.0))
                            .foregroundColor(Color(hex: "3C79E6"))
                        
                        Button(action: {
                            isSelectedAll.toggle()
                            showSpinner = true
                        }) {
                            Image(
                                isSelectedAll
                                ? GlobalConstants.redHeartImageName
                                : GlobalConstants.grayHeartName
                            )
                            .resizable()
                            .frame(width: 20.0, height: 16.0)
                        }
                    }
                }
                .padding(.horizontal, 30.0)
                Text(Constants.headerTitleName)
                    .font(.custom(GlobalConstants.regularFont, size: 20.0))
                    .foregroundColor(Color(hex: "1F2937"))
            }
            .padding(.top, 26.0)
        }
        
    }
    
    private struct ListView: View {
        @ObservedObject var viewModel: ProductsViewModel
        let sectionType: Section.SectionType
        
        var body: some View {
            ScrollView {
                VStack(spacing: 6.0) {
                    ForEach(viewModel.sections) { section in
                        if section.type == sectionType {
                            ForEach(section.products) { product in
                                CellView(viewModel: viewModel, product: product, isFavorite: product.isFavorite)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
}


