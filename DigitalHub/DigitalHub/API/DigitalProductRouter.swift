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
    
    struct Parameter {
        static let name: String = "name"
        static let id: String = "id"
    }
    
}

enum DigitalProductRouter {
    case getProducts
    case createProductWith(name: String, id:String)
    case deleteProductBY(id: String)
}

extension DigitalProductRouter: TargetType {
    
    var baseURL: URL {
        if let url = Constants.API.baseURL {
            return url
        } else {
            fatalError()
        }
    }
    
    var path: String {
        switch self {
            case .getProducts:
                return Constants.API.path
            case .createProductWith(name: _, id: _):
                return Constants.API.path
            case .deleteProductBY(id: let id):
                return Constants.API.path + "/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getProducts:
                return .get
            case .createProductWith(name: _, id: _):
                return .post
            case .deleteProductBY(id: _):
                return .delete
        }
    }
        
    var task: Moya.Task {
        switch self {
            case .getProducts:
                return Task.requestParameters(parameters: [:], encoding: URLEncoding.default)
            case .createProductWith(name: let name, id: let id):
                let parameters: [String: Any] = [
                    Constants.Parameter.name: name,
                    Constants.Parameter.id: id
                ]
                return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
            case .deleteProductBY(id: _):
                return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"]
    }
    
}



