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
        static let isFavourite = "active"
    }
    
    struct Headers {
        static let authorization: String = "Authorization"
        static let bearerToken: String = "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"
    }
    
    enum Values: String {
        case boolTrue = "true"
        case boolFalse = "false"
    }
    
    static let discontStringName: String = "Discount"
    static let fatalErrorMessage: String = "Base URL is invalid"
}

enum DigitalProductRouter {
    case getProducts
    case createProductWith(productName: String, isFavourite: Bool ,brandName: String?, imageURL: String?, price: String?, discount: String?)
    case updateProductStatusBy(id: String, isFavourite: Bool)
    case deleteProductBy(id: String)
}

extension DigitalProductRouter: TargetType {
    
    var baseURL: URL {
        guard let url = Constants.API.baseURL else { fatalError(Constants.fatalErrorMessage) }
        return url
    }
    
    var path: String {
        switch self {
            case .getProducts, .createProductWith:
                return Constants.API.path
            case .updateProductStatusBy(let id, _), .deleteProductBy(let id):
                return "\(Constants.API.path)/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getProducts:
                return .get
            case .createProductWith:
                return .post
            case .updateProductStatusBy:
                return .post
            case .deleteProductBy:
                return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
            case .getProducts:
                return .requestParameters(
                    parameters: [:],
                    encoding: URLEncoding.default
                )
                
            case .createProductWith(let productName, let isFavourite, let brandName, let imageURL, let price, let discount):
                var parameters: [String: Any] = [
                    Constants.Parameters.productName: productName,
                    Constants.Parameters.isFavourite: isFavourite ? Constants.Values.boolTrue.rawValue : Constants.Values.boolFalse.rawValue
                ]
                
                if brandName?.isEmpty == false {
                    parameters[Constants.Parameters.brandName] = brandName
                }
                
                if imageURL?.isEmpty == false {
                    parameters[Constants.Parameters.imageURL] = imageURL
                }
                
                if let discount, !discount.isEmpty {
                    let descriptor = "\(Constants.discontStringName)\(discount)"
                    parameters[Constants.Parameters.discount] = descriptor
                }
                
                if price?.isEmpty == false {
                    parameters[Constants.Parameters.price] = price
                }
                
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
                
            case .updateProductStatusBy(_, let isFavourite):
                let parameters: [String: Any] = [
                    Constants.Parameters.isFavourite: isFavourite ? Constants.Values.boolTrue.rawValue : Constants.Values.boolFalse.rawValue
                ]
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
            case .deleteProductBy:
                return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        [Constants.Headers.authorization: Constants.Headers.bearerToken]
    }
    
}


