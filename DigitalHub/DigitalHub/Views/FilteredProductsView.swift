//
//  ProductsView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 26.05.2025.
//

import SwiftUI

struct FilteredProductsView: View {
    
    // MARK: – Objects
    
    private struct Constants {
        static let headerTitleName: String = "Products"
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @State private var isAllFavoriteSelected: Bool = false
    @State private var isShowAlert: Bool = false
    
    let sectionId: UUID
    private var actionText: String {
        isAllFavoriteSelected ? "remove all" : "add all"
    }
    
    // MARK: - Main body
    
    var body: some View {
        VStack(spacing: 25.0) {
            HeaderView(viewModel: viewModel,
                       isSelectedAll: $isAllFavoriteSelected,
                       isShowAlert: $isShowAlert,
                       sectionId: sectionId)
            ListView(viewModel: viewModel, sectionId: sectionId)
        }
        .modifier(ScreenBackgroundModifier())
        .modifier(AlertModifier(viewModel: viewModel,
                                  isShowAlert: $isShowAlert,
                                  isSelectedAll: $isAllFavoriteSelected,
                                  actionText: actionText,
                                  sectionId: sectionId))
        .modifier(LoadViewModifier(viewModel: viewModel,
                                   isAllFavoriteSelected: $isAllFavoriteSelected,
                                   sectionId: sectionId))
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Environment(\.dismiss) private var dismiss: DismissAction
        @Binding var isSelectedAll: Bool
        @Binding var isShowAlert: Bool
        let sectionId: UUID

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
                    
                    if let section = viewModel.section(withId: sectionId) {
                        HStack(spacing: 6.0) {
                            Text(section.type == .favorite ? "Remove" : "Add")
                                .font(.custom(GlobalConstants.semiBoldFont, size: 10.0))
                                .foregroundColor(Color(hex: "3C79E6"))
                            
                            Button(action: {
                                isShowAlert = true
                            }) {
                                Image(
                                    isSelectedAll
                                    ? GlobalConstants.redHeartImageName
                                    : GlobalConstants.grayHeartName
                                )
                                .resizable()
                                .frame(width: 20.0, height: 16.0)
                            }
                            .disabled(section.products.isEmpty)
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
        let sectionId: UUID
        
        var body: some View {
            ScrollView {
                VStack(spacing: 6.0) {
                    if let section = viewModel.section(withId: sectionId) {
                        ForEach(section.products) { product in
                            CellView(product: product, onLikeToggle: {
                                viewModel.updateProductStatus(id: product.id, isFavourite: !product.isFavorite)
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - Modifiers
    
    private struct ScreenBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            content
                .background(Color(hex: GlobalConstants.backgroundColor))
                .navigationBarBackButtonHidden(true)
        }
        
    }
    
    private struct AlertModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var isShowAlert: Bool
        @Binding var isSelectedAll: Bool
        let actionText: String
        let sectionId: UUID
        
        func body(content: Content) -> some View {
            content
                .loadAlert(
                    isShow: $isShowAlert,
                    message: "Are you sure you want to \(actionText) ?",
                    onConfirm: {
                        viewModel.updateSectionProductsStatus(sectionId: sectionId)
                        isSelectedAll.toggle()
                        isShowAlert = false
                    },
                    onCancel: {
                        isShowAlert = false
                    }
                )
        }
        
    }
    
    private struct LoadViewModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var isAllFavoriteSelected: Bool
        let sectionId: UUID

        func body(content: Content) -> some View {
            content
                .onAppear {
                    if let section = viewModel.section(withId: sectionId) {
                        isAllFavoriteSelected = (section.type == .favorite)
                    }
                }
        }
    }
    
}


