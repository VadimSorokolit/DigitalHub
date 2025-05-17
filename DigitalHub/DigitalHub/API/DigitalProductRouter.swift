//
//  DigitalItemRouter.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import Foundation
import Moya

private struct Constants {
    
    struct API {
        static let baseURL: URL? = URL(string: "https://api.stripe.com")
        static let path: String = "v1/products"
    }
    
    struct Parameters {
        static let productName: String = "name"
        static let id: String = "id"
        static let brandName: String = "description"
        static let imageURL: String = "url"
        static let price: String = "unit_label"
        static let discount: String = "statement_descriptor"
        static let isFavorite = "active"
    }
    
    struct Headers {
        static let authorization: String = "Authorization"
        static let bearerToken: String = "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"
    }
    
    enum Values: String {
        case boolTrue = "true"
        case boolFalse = "false"
        
        static func from(_ value: Bool) -> Self {
            return value ? .boolTrue : .boolFalse
        }
    }
    
    static let discontStringName: String = "discount"
    static let fatalErrorMessage: String = "Base URL is invalid"
    static let googleURL: URL? = URL(string: "https://www.google.com")
}

enum DigitalProductRouter {
    case getProducts(startingAfter: String? = nil)
    case createProduct(product: Product)
    case updateProductStatus(id: String, isFavourite: Bool)
    case deleteProduct(id: String)
}

extension DigitalProductRouter: TargetType {
    
    private var params: [String: Any] {
        switch self {
            case .getProducts(let startingAfter):
                var parameters: [String: Any] = [:]
                if let after = startingAfter {
                    parameters["starting_after"] = after
                }
                return parameters
            case .createProduct(let product):
                var parameters: [String: Any] = [
                    Constants.Parameters.productName: product.productName,
                    Constants.Parameters.isFavorite: Constants.Values.from(product.isFavorite).rawValue
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
            case .updateProductStatus(_, let isFavourite):
                let parameters: [String: Any] = [
                    Constants.Parameters.isFavorite: Constants.Values.from(isFavourite).rawValue
                ]

                return parameters
            default:
                return [:]
        }
    }
    
    var baseURL: URL {
        guard let url = Constants.API.baseURL ?? Constants.googleURL else {
            fatalError(Constants.fatalErrorMessage)
        }
        return url
    }
    
    var path: String {
        switch self {
            case .getProducts, .createProduct:
                return Constants.API.path
            case .updateProductStatus(let id, _), .deleteProduct(let id):
                return "\(Constants.API.path)/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getProducts:
                return .get
            case .createProduct:
                return .post
            case .updateProductStatus:
                return .post
            case .deleteProduct:
                return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
            case .getProducts:
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .createProduct(_):
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .updateProductStatus(_, _):
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            case .deleteProduct:
                return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        [Constants.Headers.authorization: Constants.Headers.bearerToken]
    }
    
}


