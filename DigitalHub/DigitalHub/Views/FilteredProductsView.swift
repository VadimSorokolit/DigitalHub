//
//  FilteredProductsView.swift
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
    @State private var openCellId: String? = nil
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
            ListView(viewModel: viewModel,
                     openCellId: $openCellId,
                     sectionId: sectionId)
        }
        .modifier(ScreenBackgroundViewModifier())
        .modifier(AlertViewModifier(viewModel: viewModel,
                                    isShowAlert: $isShowAlert,
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
        private var section: ProductsSection? {
            viewModel.section(withId: sectionId)
        }
        private var headerTitleName: String {
            section?.type.rawValue.capitalized ?? ""
        }
        
        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(GlobalConstants.backButtonImageName)
                            .frame(width: 26.0, height: 24.0)
                    }
                    
                    Spacer()
                    
                    if let section = section {
                        Button(action: {
                            
                            isShowAlert = true
                        }) {
                            HStack(spacing: 6.0) {
                                Text(section.type == .favorites ? "Remove" : "Add")
                                    .font(.custom(GlobalConstants.semiBoldFont, size: 10.0))
                                    .foregroundColor(Color(hex: 0x3C79E6))
                                Image(
                                    isSelectedAll
                                    ? GlobalConstants.fillHeartImageName
                                    : GlobalConstants.emptyHeartImageName
                                )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20.0, height: 16.0)
                            }
                            .disabled(section.products.isEmpty)
                        }
                    }
                }
                .padding(.horizontal, 30.0)
                
                Text(headerTitleName)
                    .font(.custom(GlobalConstants.regularFont, size: 20.0))
                    .foregroundColor(Color(hex: 0x1F2937))
            }
            .padding(.top, 26.0)
        }
        
    }
    
    private struct ListView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var openCellId: String?
        let sectionId: UUID
        
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 6.0) {
                    if let section = viewModel.section(withId: sectionId) {
                        ForEach(section.products) { product in
                            SwipeCell(openCellId: $openCellId, id: product.id, onDelete: {
                                viewModel.updateStorageProductStatus(product, newState: .deleted) },
                                      content: {
                                CellView(
                                    product: product,
                                    onLikeToggle: {
                                        viewModel.updateStorageProductStatus(product, newState: .updated)
                                    }
                                )
                            })
                        }
                    }
                }
            }
        }
        
        private struct SwipeCell<Content: View>: View {
            @Binding var openCellId: String?
            @State private var offsetX: CGFloat = 0.0
            @GestureState private var dragX: CGFloat = 0.0
            private let swipeButtonWidth: CGFloat = 66.0
            let id: String
            let onDelete: () -> Void
            let content: () -> Content
            
            var body: some View {
                let totalOffset = offsetX + dragX
                let bgOpacity = abs(totalOffset) / swipeButtonWidth
                
                ZStack(alignment: .trailing) {
                    Rectangle()
                        .fill(Color(hex: 0xEB4132))
                        .frame(width: 250.0)
                        .frame(maxHeight: .infinity)
                        .padding(.trailing, 92.0)
                    
                    Button(action: {
                        onDelete()
                        openCellId = nil
                    }) {
                        Rectangle()
                            .fill(Color(hex: 0xEB4132).opacity(bgOpacity))
                            .animation(.easeInOut(duration: 0.25), value: bgOpacity)
                            .frame(width: 92.0)
                            .frame(maxHeight: .infinity)
                            .overlay(
                                Text("Delete")
                                    .font(.custom(GlobalConstants.regularFont, size: 12.0))
                                    .foregroundColor(.white)
                                    .offset(x: 4.0),
                                alignment: .center
                            )
                    }
                    
                    content()
                        .offset(x: totalOffset)
                        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.75, blendDuration: 0.25), value: totalOffset)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 5.0, coordinateSpace: .local)
                                .updating($dragX) { value, state, _ in
                                    let dx = value.translation.width
                                    let dy = value.translation.height
                                    if abs(dx) > abs(dy), dx < 0.0 {
                                        state = dx
                                    }
                                }
                                .onEnded { value in
                                    let dx = value.translation.width
                                    let dy = value.translation.height
                                    guard abs(dx) > abs(dy) else { return }
                                    
                                    withAnimation(.easeOut) {
                                        if offsetX + dx < -swipeButtonWidth / 2.0 {
                                            offsetX = -swipeButtonWidth
                                            openCellId = id
                                        } else {
                                            offsetX = 0.0
                                            openCellId = nil
                                        }
                                    }
                                }
                        )
                        .onChange(of: openCellId) { oldValue, newValue in
                            if newValue != id {
                                withAnimation {
                                    offsetX = 0.0
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
            
        }
    }
    
    // MARK: - Modifiers
    
    private struct ScreenBackgroundViewModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            content
                .background(Color(hex: GlobalConstants.backgroundColor))
                .navigationBarBackButtonHidden()
        }
        
    }
    
    private struct AlertViewModifier: ViewModifier {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var isShowAlert: Bool
        let actionText: String
        let sectionId: UUID
        
        func body(content: Content) -> some View {
            content
                .loadAlert(
                    isShow: $isShowAlert,
                    message: "Are you sure you want to\n\(actionText)?",
                    onConfirm: {
                        isShowAlert = false
                        viewModel.updateProductsStatus(sectionId: sectionId)
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
                        isAllFavoriteSelected = (section.type == .favorites)
                    }
                }
                .onReceive(viewModel.$isLoading) { isLoading in
                    if !isLoading {
                        if let section = viewModel.section(withId: sectionId) {
                            if section.products.isEmpty {
                                isAllFavoriteSelected = (section.type == .unfavorites)
                            }
                        }
                    }
                }
        }
        
    }
    
}


