//
//  AddProductView.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 05.06.2025.
//
    
import SwiftUI
import PhotosUI

struct AddProductView: View {
    
    // MARK: Objects
    
    private struct Constants {
        static let headerViewTitle: String = "Add Product"
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @State var product = Product()
    @State var producName: String = ""
    @State var brandName: String? = nil
    @State var imageURL: String? = nil
    @State var isFavorite: Bool = false
    @State var price: String? = nil
    @State var discount: String? = nil
    @State var pickerItem: PhotosPickerItem? = nil
    @State var pickedImage: UIImage?
    @State var didSaveProduct: Bool = false
    @State var isPlaceholder: Bool = true
    
    // MARK: - Main body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 150.0) {
                VStack(spacing: 36.0) {
                    HeaderView(viewModel: viewModel)
                    ProductView(producName: $producName, brandName: $brandName, imageURL: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount, pickerItem: $pickerItem, pickedImage: $pickedImage, didSaveProduct: $didSaveProduct)
                }
                
                AddProductButtonView(viewModel: viewModel, pickedImage: $pickedImage, product: $product)
            }
        }
        .modifier(ProductFieldsModifier(viewModel: viewModel, product: $product, producName: $producName, brandName: $brandName, imageURL: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount, pickerItem: $pickerItem, pickedImage: $pickedImage, didSaveProduct: $didSaveProduct))
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
                
                Text(Constants.headerViewTitle.localizedCapitalized)
                    .frame(width: 140.0)
                    .font(.custom(GlobalConstants.mediumFont, size: 20.0))
                    .foregroundColor(Color(hex: 0x1F2937))
            }
            .padding(.top, 36.0)
            .padding(.horizontal, 18.0)
        }
        
    }
    
    private struct CellView: View, Identifiable {
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var didSaveProduct: Bool
        let id = UUID()
        var isPlaceholder: Bool
        
        var body: some View {
            VStack(spacing: 29.0) {
                ImageView(imageURL: $imageURL, pickerItem: $pickerItem, pickedImage: $pickedImage)
                InfoView(producName: $producName, brandName: $brandName, imageURLString: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount)
            }
            .frame(width: 290.0)
            .padding([.top, .bottom, .horizontal], 22.0)
            .background(Color(hex: GlobalConstants.productCellColor))
            .cornerRadius(36.0)
        }
        
        private struct ImageView: View {
            @Binding var imageURL: String?
            @Binding var pickerItem: PhotosPickerItem?
            @Binding var pickedImage: UIImage?
            private let width: CGFloat = 290.0
            private let height: CGFloat = 234.0
            private let cornerRadius: CGFloat = 18.0
            
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: 0xECECEC))
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                    
                    if let uiImage = pickedImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                    } else {
                        Image(systemName: GlobalConstants.placeholderImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width / 2.0, height: height / 2.0)
                            .foregroundColor(Color(hex: 0xD2D4D8))
                    }
                    
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Color.clear.frame(width: width, height: height)
                    }
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
                    isFavorite.toggle()
                }) {
                    (isFavorite
                     ? Image(GlobalConstants.redHeartImageName)
                     : Image(GlobalConstants.grayHeartImageName))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50.0, height: 45.0)
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
    
    private struct ProductView: View {
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var didSaveProduct: Bool
        
        var body: some View {
            ZStack {
                CellView(
                    producName: .constant(""),
                    brandName: .constant(nil),
                    imageURL: .constant(nil),
                    isFavorite: .constant(false),
                    price: .constant(nil),
                    discount: .constant(nil),
                    pickerItem: .constant(nil),
                    pickedImage: .constant(nil),
                    didSaveProduct: .constant(false),
                    isPlaceholder: true
                )
                .allowsHitTesting(false)
                .redacted(reason: .invalidated)
                
                CellView(
                    producName: $producName,
                    brandName: $brandName,
                    imageURL: $imageURL,
                    isFavorite: $isFavorite,
                    price: $price,
                    discount: $discount,
                    pickerItem: $pickerItem,
                    pickedImage: $pickedImage,
                    didSaveProduct: $didSaveProduct,
                    isPlaceholder: false
                )
                .rotationEffect(.degrees(didSaveProduct ? 100.0 : 0.0), anchor: .bottomTrailing)
                .offset(x: didSaveProduct ? 30.0 : 0.0)
                .animation(didSaveProduct ? .easeOut(duration: 0.35) : .easeIn(duration: 0.001), value: didSaveProduct)
            }
        }
        
    }
    
    private struct AddProductButtonView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var pickedImage: UIImage?
        @Binding var  product: Product
        
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
                    if let imageData = pickedImage?.jpegData(compressionQuality: 1.0) {
                        viewModel.createFile(imageData)
                    } else {
                        viewModel.createProduct(product)
                    }
                }
            }
            .opacity(product.isValid ? 1.0 : 0.5)
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
        @ObservedObject var viewModel: ProductsViewModel
        @Binding var product: Product
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var didSaveProduct: Bool
        
        func body(content: Content) -> some View {
            content
                .onChange(of: viewModel.isLoading) {
                    if !viewModel.isLoading, viewModel.errorMessage == nil {
                        didSaveProduct.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                            producName = ""
                            brandName = nil
                            imageURL = nil
                            isFavorite = false
                            price = nil
                            discount = nil
                            pickedImage = nil
                            didSaveProduct = false
                        }
                    }
                }
                .onChange(of: producName) {
                    product.name = producName
                }
                .onReceive(viewModel.$fileLinkURL) { newURL in
                    guard let url = newURL else { return }
                    product.imageURL = url
                    viewModel.createProduct(product)
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
                .onChange(of: pickerItem) {
                    Task {
                        if let data = try? await pickerItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            pickedImage = image
                        }
                    }
                }
        }
        
    }
}

#Preview {
    let viewModel = ProductsViewModel(apiClient: MoyaClient())
    let product = Product()
    
    AddProductView(viewModel: viewModel, product: product)
}
