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
        static let animationDuration: Double = 0.35
        static let fillHeartImageName: String = "largeRedHeart"
        static let emptyHeartImageName: String = "largeGrayHeart"
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ProductsViewModel
    @ObservedObject var networMonitor: NetworkMonitor
    @State var product = StorageProduct()
    @State private var productName: String = ""
    @State private var brandName: String? = nil
    @State private var imageURL: String? = nil
    @State private var isFavorite: Bool = false
    @State private var price: String? = nil
    @State private var discount: String? = nil
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage?
    @State private var didSwipe = false
    @State private var copyProduct = StorageProduct()
    @State private var showNoInternetAlert = false
    
    // MARK: - Main body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 150.0) {
                VStack(spacing: 36.0) {
                    HeaderView(viewModel: viewModel)
                    ProductView(productName: $productName, brandName: $brandName, imageURL: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount, pickerItem: $pickerItem, pickedImage: $pickedImage, didSwipe: $didSwipe, showNoInternetAlert: $showNoInternetAlert)
                }
                
                AddProductButtonView(viewModel: viewModel, networkMonitor: networMonitor, pickedImage: $pickedImage, product: $product, didSwipe: $didSwipe)
            }
        }
        .modifier(ProductFieldsModifier(viewModel: viewModel, storageProduct: $product, producName: $productName, brandName: $brandName, imageURL: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount, pickerItem: $pickerItem, pickedImage: $pickedImage, didSwipe: $didSwipe, copyProduct: $copyProduct))
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
    
    private struct CellView: View {
        @Binding var productName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var showNoInternetAlert: Bool
        
        init() {
            _productName = .constant("")
            _brandName = .constant(nil)
            _imageURL = .constant(nil)
            _isFavorite = .constant(false)
            _price = .constant(nil)
            _discount = .constant(nil)
            _pickerItem = .constant(nil)
            _pickedImage = .constant(nil)
            _showNoInternetAlert = .constant(false)
        }
        
        init(
            producName: Binding<String>,
            brandName: Binding<String?>,
            imageURL: Binding<String?>,
            isFavorite: Binding<Bool>,
            price: Binding<String?>,
            discount: Binding<String?>,
            pickerItem: Binding<PhotosPickerItem?>,
            pickedImage: Binding<UIImage?>,
            showNoInternetAlert: Binding<Bool>
        ) {
            _productName = producName
            _brandName = brandName
            _imageURL = imageURL
            _isFavorite = isFavorite
            _price = price
            _discount = discount
            _pickerItem = pickerItem
            _pickedImage = pickedImage
            _showNoInternetAlert = showNoInternetAlert
        }
        
        var body: some View {
            VStack(spacing: 29.0) {
                ImageView(imageURL: $imageURL, pickerItem: $pickerItem, pickedImage: $pickedImage, showNoInternetAlert: $showNoInternetAlert)
                InfoView(producName: $productName, brandName: $brandName, imageURLString: $imageURL, isFavorite: $isFavorite, price: $price, discount: $discount)
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
            @Binding var showNoInternetAlert: Bool
            private let width: CGFloat = 290.0
            private let height: CGFloat = 234.0
            private let sizeDivider: CGFloat = 2.0
            private let cornerRadius: CGFloat = 18.0
            
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: GlobalConstants.cellImagePlaceholderBackgroundColor))
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius)

                    if let image = pickedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                            .cornerRadius(cornerRadius)
                    } else {
                        Image(systemName: GlobalConstants.placeholderImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width / sizeDivider, height: height / sizeDivider)
                            .foregroundColor(Color(hex: GlobalConstants.cellImagePlaceholderColor))
                    }

                    if NetworkMonitor.shared.isConnected {
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Color.clear.frame(width: width, height: height)
                        }
                    } else {
                        Color.clear
                            .frame(width: width, height: height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showNoInternetAlert = true
                            }
                    }
                }
                .alert("No Internet Connection", isPresented: $showNoInternetAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("You need to be connected to the internet to pick an image.")
                }
            }
            
        }
        
        private struct InfoView: View {
            @Binding var producName: String
            @Binding var brandName: String?
            @Binding var imageURLString: String?
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
                .keyboardType(.numberPad)
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
                    
                    CustomTextField(optionalText: $discount, placeholder: "Tax", leadinPadding: 4.0, width: 34.0, height: 12.0, fontSize: 10.0, cornerRadius: 3.0)
                }
                .offset(x: 23.0, y: -7.0)
                .keyboardType(.numberPad)
            }
            
        }
        
        private struct LikeImageViewButton: View {
            @Binding var isFavorite: Bool
            
            var body: some View {
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(isFavorite ? Constants.fillHeartImageName : Constants.emptyHeartImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50.0, height: 45.0)
                }
            }
            
        }
        
        private struct CustomTextField: View {
            @Binding var rawText: String?
            private let placeholder: String
            private let padding: CGFloat
            private let width: CGFloat
            private let height: CGFloat
            private let fontSize: CGFloat
            private let cornerRadius: CGFloat
            
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
        @Binding var productName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var didSwipe: Bool
        @Binding var showNoInternetAlert: Bool
        
        var body: some View {
            ZStack {
                CellView()
                    .allowsHitTesting(false)
                    .redacted(reason: .invalidated)
                
                CellView(
                    producName: $productName,
                    brandName: $brandName,
                    imageURL: $imageURL,
                    isFavorite: $isFavorite,
                    price: $price,
                    discount: $discount,
                    pickerItem: $pickerItem,
                    pickedImage: $pickedImage,
                    showNoInternetAlert: $showNoInternetAlert
                )
                .rotationEffect(.degrees(didSwipe ? 20.0 : 0.0), anchor: UnitPoint(x: 2.0, y: 5.0))
                .animation(didSwipe ? Animation.easeInOut(duration: Constants.animationDuration) : nil, value: didSwipe)
            }
        }
        
    }
    
    private struct AddProductButtonView: View {
        @ObservedObject var viewModel: ProductsViewModel
        @ObservedObject var networkMonitor: NetworkMonitor
        @Binding var pickedImage: UIImage?
        @Binding var product: StorageProduct
        @Binding var didSwipe: Bool
        
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
            .onTapGesture {
                if product.isValid {
                    didSwipe = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
                        didSwipe = false
                        if let imageData = pickedImage?.jpegData(compressionQuality: 1.0) {
                            viewModel.createFile(imageData)
                        } else {
                            viewModel.createStorageProduct(product)
                        }
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
        @Binding var storageProduct: StorageProduct
        @Binding var producName: String
        @Binding var brandName: String?
        @Binding var imageURL: String?
        @Binding var isFavorite: Bool
        @Binding var price: String?
        @Binding var discount: String?
        @Binding var pickerItem: PhotosPickerItem?
        @Binding var pickedImage: UIImage?
        @Binding var didSwipe: Bool
        @Binding var copyProduct: StorageProduct
        
        func body(content: Content) -> some View {
            content
                .onChange(of: didSwipe) {
                    if !didSwipe {
                        copyProduct = storageProduct.copy()
                        producName = ""
                        brandName = nil
                        imageURL = nil
                        isFavorite = false
                        price = nil
                        discount = nil
                        pickedImage = nil
                        storageProduct = StorageProduct()
                    }
                }
                .onChange(of: producName) {
                    storageProduct.name = producName
                }
                .onChange(of: brandName) {
                    storageProduct.brandName = brandName
                }
                .onReceive(viewModel.$fileLinkURL) { newURL in
                    guard let url = newURL else { return }
                    copyProduct.imageURL = url
                    viewModel.createStorageProduct(copyProduct)
                }
                .onChange(of: isFavorite) {
                    storageProduct.isFavorite = isFavorite
                }
                .onChange(of: price) {
                    if let price = price {
                        storageProduct.price = "$ \(price)"
                    } else {
                        storageProduct.price = "--"
                    }
                }
                .onChange(of: discount) {
                    if let discount = discount {
                        storageProduct.discount = "- \(discount) %"
                    } else {
                        storageProduct.discount = "--"
                    }
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
