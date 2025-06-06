//
//  AddProductView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 05.06.2025.
//
    
import SwiftUI

struct AddProductView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @State var product = Product()
    @State var producName: String = ""
    @State var brandName: String? = nil
    @State var imageURLString: String? = nil
    @State var isFavorite: Bool = false
    @State var price: String? = nil
    @State var discount: String? = nil
    
    // MARK: - Main body
    
    var body: some View {
        VStack {
            VStack(spacing: 36.0) {
                HeaderView(viewModel: viewModel)
                CellView(producName: $producName, brandName: $brandName, imageURLString: $imageURLString, isFavorite: $isFavorite, price: $price, discount: $discount)
            }
            
            Spacer()
            
            AddProductButtonView(viewModel: viewModel, product: product)
        }
        .modifier(ProductFieldsModifier(product: $product, producName: $producName, brandName: $brandName, imageURLString: $imageURLString, isFavorite: $isFavorite, price: $price, discount: $discount))
        .modifier(ScreenBackgroundModifier())
    }
    
    // MARK: - Subviews
    
    private struct HeaderView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Environment(\.dismiss) private var dismiss: DismissAction
        
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
                }
                
                Text("Add Product")
                    .frame(width: 140.0)
                    .font(.custom(GlobalConstants.regularFont, size: 20.0))
                    .foregroundColor(Color(hex: 0x1F2937))
            }
            .padding(.top, 36.0)
            .padding(.horizontal, 18.0)
        }
        
    }
    
    private struct CellView: View {
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var imageURLString: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        
        var body: some View {
            VStack(spacing: 29.0) {
                ImageView(imageURLString: $imageURLString)
                InfoView(producName: $producName, brandName: $brandName, imageURLString: $imageURLString, isFavorite: $isFavorite, price: $price, discount: $discount)
            }
            .frame(width: 290.0)
            .padding([.top, .bottom, .horizontal], 22.0)
            .background(Color(hex: GlobalConstants.productCellColor))
            .cornerRadius(36.0)
        }
        
        private struct ImageView: View {
            @Binding var  imageURLString: String?
            
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: 0xECECEC))
                        .frame(width: 290.0, height: 234.0)
                        .cornerRadius(18.0, corners: [.topLeft, .topRight])
                    
                    Image(systemName: GlobalConstants.placeholderImageName)
                        .resizable()
                        .foregroundColor(Color(hex: 0xD2D4D8))
                        .frame(width: 290.0 / 2.0, height: 234.0 / 2.0)
                }
            }
            
        }
        
        private struct InfoView: View {
            @Binding var producName: String
            @Binding var brandName: String?
            @Binding var  imageURLString: String?
            @Binding var isFavorite: Bool
            @Binding var price: String?
            @Binding var discount: String?
            
            var body: some View {
                VStack(spacing: 19.0) {
                    TextFieldsView(producName: $producName, brandName: $brandName)
                    PriceWithLikeView(isFavorite: $isFavorite, price: $price, discount: $discount)
                }
            }
            
        }
        
        private struct TextFieldsView: View {
            @Binding var producName: String
            @Binding var brandName: String?
            
            var body: some View {
                VStack(alignment: .leading, spacing: 13.0) {
                    CustomTextField(text: $producName, placeholder: "Product name", leadinPadding: 10.0, width: 289.0, height: 36.0, fontSize: 12.0, cornerRadius: 11.0)
                    
                    CustomTextField(optionalText: $brandName, placeholder: "Brand name", leadinPadding: 10.0, width: 189.0, height: 22.0, fontSize: 10.0, cornerRadius: 6.0)
                }
            }
            
        }
        
        private struct PriceWithLikeView: View {
            @Binding var isFavorite: Bool
            @Binding var price: String?
            @Binding var discount: String?
            
            var body: some View {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        PriceView(price: $price)
                        DiscountView(discount: $discount)
                    }
                    
                    Spacer()
                    
                    LikeImageViewButton(isFavorite: $isFavorite)
                }
            }
            
        }
        
        private struct PriceView: View {
            @Binding var price: String?
            
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.priceLabelColor))
                        .frame(width: 114.0, height: 46.0)
                        .cornerRadius(6.79, corners: [.topLeft, .topRight, .bottomRight])
                        .cornerRadius(22.64, corners: [.bottomLeft])
                    
                    CustomTextField(optionalText: $price, placeholder: "Price", leadinPadding: 8.0, width: 60.0, height: 22.0, fontSize: 10.0, cornerRadius: 6.0)
                }
            }
            
        }
        
        struct DiscountView: View {
            @Binding var discount: String?
            
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.discountLabelColor))
                        .frame(width: 52.0, height: 21.0)
                        .cornerRadius(7.0)
                    
                    CustomTextField(optionalText: $discount, placeholder: "Discount", leadinPadding: 4.0, width: 34.0, height: 12.0, fontSize: 4.0, cornerRadius: 3.0)
                }
                .offset(x: 23.0, y: -7.0)
            }
            
        }
        
        private struct LikeImageViewButton: View {
            @Binding var isFavorite: Bool
            
            var body: some View {
                Button(action: {
                    
                }) {
                    Image(GlobalConstants.redHeartImageName)
                        .resizable()
                        .frame(width: 50.0, height: 45.0)
                        .scaledToFit()
                }
            }
            
        }
        
        private struct CustomTextField: View {
            @Binding var rawText: String?
            let placeholder: String
            let padding: CGFloat
            let width: CGFloat
            let height: CGFloat
            let fontSize: CGFloat
            let cornerRadius: CGFloat
            
            init(
                text: Binding<String>,
                placeholder: String,
                leadinPadding: CGFloat,
                width: CGFloat,
                height: CGFloat,
                fontSize: CGFloat,
                cornerRadius: CGFloat
            ) {
                self._rawText = Binding<String?>(
                    get: { text.wrappedValue },
                    set: { newValue in text.wrappedValue = newValue ?? "" }
                )
                self.placeholder = placeholder
                self.padding = leadinPadding
                self.width = width
                self.height = height
                self.fontSize = fontSize
                self.cornerRadius = cornerRadius
            }
            
            init(
                optionalText: Binding<String?>,
                placeholder: String,
                leadinPadding: CFloat,
                width: CGFloat,
                height: CGFloat,
                fontSize: CGFloat,
                cornerRadius: CGFloat
            ) {
                self._rawText = optionalText
                self.placeholder = placeholder
                self.padding = CGFloat(leadinPadding)
                self.width = width
                self.height = height
                self.fontSize = fontSize
                self.cornerRadius = cornerRadius
            }
            
            var body: some View {
                TextField(
                    "",
                    text: Binding(
                        get: { rawText ?? "" },
                        set: { newValue in
                            rawText = newValue.isEmpty ? nil : newValue
                        }
                    ),
                    prompt: Text(placeholder)
                        .foregroundColor(Color(hex: 0x9CA3AF))
                )
                .padding(.leading, padding)
                .frame(width: width, height: height)
                .font(.custom(GlobalConstants.regularFont, size: fontSize))
                .background(Color(hex: 0xE6E7E9))
                .cornerRadius(cornerRadius)
            }
        }
    }
    
    private struct AddProductButtonView: View {
        let viewModel: ProductsViewModel
        let product: Product
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color(hex: 0x32B768))
                    .frame(width: 188.0, height: 60.0)
                    .cornerRadius(17.0)
                
                Text("Save")
                    .foregroundColor(.white)
                    .font(.custom(GlobalConstants.semiBoldFont, size: 26.0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if product.isValid {
                    viewModel.createProduct(product)
                }
            }
            .opacity(product.isValid ? 1.0 : 0.5)
            .padding(.bottom, 70.0)
        }
        
    }
    
    // MARK: - Modifiers
    
    private struct ScreenBackgroundModifier: ViewModifier {
        
        func body(content: Content) -> some View {
            content
                .navigationBarBackButtonHidden()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(hex: GlobalConstants.backgroundColor))
        }
        
    }
    
    struct ProductFieldsModifier: ViewModifier {
        @Binding var product: Product
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var  imageURLString: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        
        func body(content: Content) -> some View {
            content
                .onChange(of: producName) {
                    product.name = producName
                }
                .onChange(of: imageURLString) {
                    product.imageURL = imageURLString
                }
                .onChange(of: isFavorite) {
                    product.isFavorite = isFavorite
                }
                .onChange(of: price) {
                    product.price = price
                }
                .onChange(of: discount) {
                    product.discount = discount
                }
        }
        
    }
}

#Preview {
    let viewModel = ProductsViewModel(apiClient: MoyaClient())
    let product = Product()
    
    AddProductView(viewModel: viewModel, product: product)
}
