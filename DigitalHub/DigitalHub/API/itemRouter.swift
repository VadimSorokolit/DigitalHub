//
//  Untitled.swift
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

enum DigitalItemRouter {
    case searchItems
    case createItemWith(name: String, id:String)
    case deleteItemBY(id: String)
}

extension DigitalItemRouter: TargetType {
    var baseURL: URL {
        if let url = Constants.API.baseURL {
            return url
        } else {
            fatalError()
        }
    }
    
    var path: String {
        switch self {
                case .searchItems:
                return Constants.API.path
            case .createItemWith(name: _, id: _):
                return Constants.API.path
            case .deleteItemBY(id: let id):
                return Constants.API.path + "/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .searchItems:
                return .get
            case .createItemWith(name: _, id: _):
                return .post
            case .deleteItemBY(id: _):
                return .delete
        }
    }
        
    var task: Moya.Task {
        switch self {
            case .searchItems:
                return Task.requestParameters(parameters: [:], encoding: URLEncoding.default)
            case .createItemWith(name: let name, id: let id):
                let parameters: [String: Any] = [
                    Constants.Parameter.name: name,
                    Constants.Parameter.id: id
                ]
                return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
            case .deleteItemBY(id: _):
                return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"]
    }
    
}



