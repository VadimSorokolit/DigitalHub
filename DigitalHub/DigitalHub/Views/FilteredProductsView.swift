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
        static let headerTitleName: String = "Products"
    }
    
    @ObservedObject var viewModel: ProductsViewModel
    @State private var isSelectedAll: Bool = false
    @State private var showSpinner: Bool = false
    
    var sectionType: Section.SectionType
    private var actionText: String {
        isSelectedAll ? "add all" : "remove all"
    }

    var body: some View {
        VStack(spacing: 25.0) {
            HeaderView(viewModel: viewModel,
                       isSelectedAll: $isSelectedAll, showSpinner: $showSpinner, sectionType: sectionType)
            ListView(viewModel: viewModel, sectionType: sectionType)
        }
        .modifier(ScreenBackgroundModifier())
        .modifier(SpinnerModifier(viewModel: viewModel, showSpinner: $showSpinner,
                                  isSelectedAll: $isSelectedAll, actionText: actionText, sectionType: sectionType))
        .modifier(LoadViewModifier(isSelectedAll: $isSelectedAll, sectionType: sectionType))

    }
    
    private struct HeaderView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Environment(\.dismiss) private var dismiss: DismissAction
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
    
    private struct ScreenBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            content
                .background(Color(hex: GlobalConstants.backgroundColor))
                .navigationBarBackButtonHidden(true)
        }
        
    }
    
    private struct SpinnerModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var showSpinner: Bool
        @Binding var isSelectedAll: Bool
        
        let actionText: String
        let sectionType: Section.SectionType
        
        func body(content: Content) -> some View {
            content
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
        }
        
    }
    
    private struct LoadViewModifier: ViewModifier {
        @Binding var isSelectedAll: Bool
        let sectionType: Section.SectionType
        
        func body(content: Content) -> some View {
            content
                .onAppear {
                    isSelectedAll = (sectionType == .favorite)
                }
        }
        
    }
    
}


