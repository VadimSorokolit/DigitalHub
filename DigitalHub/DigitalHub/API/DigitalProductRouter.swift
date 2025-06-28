//
//  DigitalItemRouter.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import Foundation
import Moya

/**
 - Note:
 API Docs: - https://docs.stripe.com/api/products
 */

private struct Constants {
    
    struct API {
        static let productURL: URL? = URL(string: "https://api.stripe.com")
        static let fileURL: URL? = URL(string: "https://files.stripe.com")
        static let productsPath: String = "v1/products"
        static let searchPath: String = "v1/products/search"
        static let filePath: String = "v1/files"
        static let fileLinkPath: String = "v1/file_links"
    }
    
    struct Parameters {
        static let productName: String = "name"
        static let id: String = "id"
        static let query: String = "query"
        static let brandName: String = "description"
        static let imageURL: String = "url"
        static let price: String = "unit_label"
        static let discount: String = "statement_descriptor"
        static let isFavorite: String = "active"
        static let startingAfter: String = "starting_after"
        static let productsLimit: String = "limit"
        static let page: String = "page"
        static let filePurpose: String = "purpose"
        static let fileName: String = "file"
        
        static func queryValue(for searchString: String) -> String {
            return #"name~"\#(searchString)""#
        }
    }
    
    struct Headers {
        static let authorization: String = "Authorization"
        static let bearerToken: String = "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"
    }
    
    struct Values {
        static let perPage: Int = 15
        
        enum BoolString: String {
            case boolTrue = "true"
            case boolFalse = "false"
            
            static func from(_ value: Bool) -> Self {
                return value ? .boolTrue : .boolFalse
            }
        }
    }
    static let discontStringName: String = "discount"
    static let fatalErrorMessage: String = "URL is invalid"
    static let filetype: String = "tax_document_user_upload"
    static let defaultURL: URL? = URL(string: "https://www.google.com")
    static let fileFieldName: String = "file"
    static let fileName: String = "image.jpg"
    static let mimoType: String = "image/jpeg"
}

enum DigitalProductRouter {
    case getProducts(startingAfterId: String? = nil)
    case searchProducts(name: String, startingAfterId: String? = nil)
    case createProduct(product: Product)
    case createFile(data: Data)
    case createFileLink(_ fileLinkId: String?)
    case updateProductStatus(id: String, isFavorite: Bool)
    case deleteProduct(id: String)
}

extension DigitalProductRouter: TargetType {
    
    private var params: [String: Any] {
        switch self {
            case .getProducts(let productId):
                var parameters: [String: Any] = [
                    Constants.Parameters.productsLimit: Constants.Values.perPage
                ]
                
                if let productId {
                    parameters[Constants.Parameters.startingAfter] = productId
                }
                return parameters
                
            case .createFileLink(let fileLinkId):
                var parameters: [String: Any] = [:]
                if let fileLinkId {
                    parameters[Constants.Parameters.fileName] = fileLinkId
                }
                return parameters
                
            case .searchProducts(let query, let page):
                var parameters: [String: Any] = [
                    Constants.Parameters.productsLimit: Constants.Values.perPage,
                    Constants.Parameters.query: Constants.Parameters.queryValue(for: query)
                ]
                
                if let page {
                    parameters[Constants.Parameters.page] = page
                }
                return parameters
                
            case .createProduct(let product):
                var parameters: [String: Any] = [
                    Constants.Parameters.productName: product.name,
                    Constants.Parameters.id: product.id,
                    Constants.Parameters.isFavorite: Constants.Values.BoolString.from(product.isFavorite).rawValue
                ]
                
                if product.brandName?.isEmpty == false {
                    parameters[Constants.Parameters.brandName] = product.brandName
                }
                if product.imageURL?.isEmpty == false {
                    parameters[Constants.Parameters.imageURL] = product.imageURL
                }
                if let discount = product.discount, !discount.isEmpty {
                    let descriptor = "\(Constants.discontStringName)\(discount)"
                    parameters[Constants.Parameters.discount] = descriptor
                }
                if product.price?.isEmpty == false {
                    parameters[Constants.Parameters.price] = product.price
                }
                return parameters
                
            case .updateProductStatus(_, let isFavorite):
                let parameters: [String: Any] = [
                    Constants.Parameters.isFavorite: Constants.Values.BoolString.from(isFavorite).rawValue]
                return parameters
            default:
                return [:]
        }
    }
    
    var baseURL: URL {
        switch self {
            case .createFile:
                guard let url = Constants.API.fileURL ?? Constants.defaultURL else {
                    fatalError(Constants.fatalErrorMessage)
                }
                return url
                
            default:
                guard let url = Constants.API.productURL ?? Constants.defaultURL else {
                    fatalError(Constants.fatalErrorMessage)
                }
                return url
        }
    }
    
    var path: String {
        switch self {
            case .getProducts,.createProduct:
                return Constants.API.productsPath
            case .createFileLink:
                return Constants.API.fileLinkPath
            case .searchProducts:
                return Constants.API.searchPath
            case .updateProductStatus(let id, _), .deleteProduct(let id):
                return "\(Constants.API.productsPath)/\(id)"
            case .createFile:
                return Constants.API.filePath
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getProducts, .searchProducts:
                return .get
            case .createFileLink, .createFile, .updateProductStatus, .createProduct:
                return .post
            case .deleteProduct:
                return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
            case .getProducts:
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .createFileLink:
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .searchProducts:
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .createProduct(_):
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .updateProductStatus(_, _):
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .deleteProduct:
                return .requestPlain
            case .createFile(let data):
                let formData: [MultipartFormData] = [
                    MultipartFormData(provider: .data(data),
                                      name: Constants.fileFieldName,
                                      fileName: Constants.fileName,
                                      mimeType: Constants.mimoType),
                    MultipartFormData(provider: .data(Constants.filetype.data(using: .utf8) ?? Data()),
                                      name: Constants.Parameters.filePurpose)
                ]
                return .uploadMultipart(formData)
        }
    }
    
    var headers: [String: String]? {
        [Constants.Headers.authorization: Constants.Headers.bearerToken]
    }
    
}


