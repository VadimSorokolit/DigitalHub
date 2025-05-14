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
        static let authorization = "Authorization"
        static let bearerToken = "Bearer sk_test_51QqY1YRvGwnRrL9T73pkGR9tOby4upVse7KDYQtvHqBEhpVEM8FlVz8JMXxxXEGG9C2bqbCk3HQ7S5FmxUNIEkpk00jWWfn0om"
    }
    
    struct API {
        static let baseURL: URL? = URL(string: "https://api.stripe.com")
        static let path: String = "v1/products"
    }

    struct Parameter {
        static let productName: String = "name"
        static let brandName: String = "description"
        static let imageURL: String = "url"
        static let discount: String = "tax_code"
        static let expandDefaultPrice: String = "expand[]"
        static let defaultCurrency: String = "uah"

        struct DefaultPriceData {
            static let key = "default_price_data"
            static let currency = "currency"
            static let unitAmount = "unit_amount"
        }
    }

    struct Expand {
        static let defaultPrice: String = "default_price"
        static let dataDefaultPrice: String = "data.default_price"
    }
}

enum DigitalProductRouter {
    case getProducts
    case createProductWith(productName: String, brandName: String?, imageURL: String?, price: String?, discount: String?)
    case deleteProductBY(id: String)
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
            case .deleteProductBY(let id):
                return "\(Constants.API.path)/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
            case .getProducts:
                return .get
            case .createProductWith:
                return .post
            case .deleteProductBY:
                return .delete
        }
    }

    var task: Moya.Task {
        switch self {
            case .getProducts:
                return .requestParameters(
                    parameters: [Constants.Parameter.expandDefaultPrice: Constants.Expand.dataDefaultPrice],
                    encoding: URLEncoding.default
                )

            case .createProductWith(let productName, let brandName, let imageURL, let price, let discount):
                var parameters: [String: Any] = [
                    Constants.Parameter.productName: productName,
                    Constants.Parameter.expandDefaultPrice: Constants.Expand.defaultPrice
                ]
                
                if let brandName = brandName, !brandName.isEmpty {
                    parameters[Constants.Parameter.brandName] = brandName
                }

                if let url = imageURL, !url.isEmpty {
                    parameters[Constants.Parameter.imageURL] = url
                }

                if let taxCode = discount, !taxCode.isEmpty {
                    parameters[Constants.Parameter.discount] = taxCode
                }

                if let price = price, let priceInt = Int(price) {
                    parameters[Constants.Parameter.DefaultPriceData.key] = [
                        Constants.Parameter.DefaultPriceData.currency: Constants.Parameter.defaultCurrency,
                        Constants.Parameter.DefaultPriceData.unitAmount: priceInt * 100
                    ]
                }

                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

            case .deleteProductBY:
                return .requestPlain
        }
    }

    var headers: [String: String]? {
        [Constants.Header.authorization: Constants.Header.bearerToken]
    }
}


