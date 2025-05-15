//
//  DigitalItemRouter.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    
import Foundation
import Moya

private struct Constants {
    
    struct Header {
        static let authorization: String = "Authorization"
        static let bearerToken: String = "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"
    }
    
    struct API {
        static let baseURL: URL? = URL(string: "https://api.stripe.com")
        static let path: String = "v1/products"
    }

    struct Parameter {
        static let productName: String = "name"
        static let brandName: String = "description"
        static let imageURL: String = "url"
        static let price: String = "unit_label"
        static let discount: String = "statement_descriptor"
    }
    
    static let discontStringName: String = "Discount"

}

enum DigitalProductRouter {
    case getProducts
    case createProductWith(productName: String, brandName: String?, imageURL: String?, price: String?, discount: String?)
    case deleteProductBy(id: String)
}

extension DigitalProductRouter: TargetType {
    
    var baseURL: URL {
        guard let url = Constants.API.baseURL else { fatalError("Base URL is invalid") }
        return url
    }
    
    var path: String {
        switch self {
            case .getProducts, .createProductWith:
                return Constants.API.path
            case .deleteProductBy(let id):
                return "\(Constants.API.path)/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getProducts:
                return .get
            case .createProductWith:
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
                
            case .createProductWith(let productName, let brandName, let imageURL, let price, let discount):
                var parameters: [String: Any] = [
                    Constants.Parameter.productName: productName,
                ]
                
                if brandName?.isEmpty == false {
                    parameters[Constants.Parameter.brandName] = brandName
                }
                
                if imageURL?.isEmpty == false {
                    parameters[Constants.Parameter.imageURL] = imageURL
                }
                
                if let discount, !discount.isEmpty {
                    let descriptor = "\(Constants.discontStringName)\(discount)"
                    parameters[Constants.Parameter.discount] = descriptor
                }
                
                if price?.isEmpty == false {
                    parameters[Constants.Parameter.price] = price
                }
                
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
                
            case .deleteProductBy:
                return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        [Constants.Header.authorization: Constants.Header.bearerToken]
    }
    
}


