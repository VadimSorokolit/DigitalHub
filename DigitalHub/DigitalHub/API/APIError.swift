//
//  APIError.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 17.03.2025.
//
    
import Foundation
import Moya
import Alamofire

enum APIError: LocalizedError {
    
    case noInternet
    case networkError(Error)
    case decodingError(Error)
    case custom
    case serverError(statusCode: Int)
    case invalidURL
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .noInternet:
                return "No internet connection"
            case .networkError(let err):
                return "Network Error: \(err.localizedDescription)"
            case .decodingError(let err):
                return "Decoding Error: \(err.localizedDescription)"
            case .serverError(let statusCode):
                return "Server Error (Code: \(statusCode))"
            case .invalidURL:
                return "Invalid URL provided"
            case .unknown:
                return "An unknown error occurred"
            case .custom:
                return "Error: Product name cannot be empty"
        }
    }
    
    static func from(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        if let afError = error.asAFError {
            switch afError {
                case .responseValidationFailed(let reason):
                    switch reason {
                        case .unacceptableStatusCode(let code):
                            if code == 404 {
                                return .invalidURL
                            } else {
                                return .serverError(statusCode: code)
                            }
                        default:
                            return .unknown
                    }
                case .invalidURL(_):
                    return .invalidURL
                case .sessionTaskFailed(let underlyingError):
                    if let urlError = underlyingError as? URLError {
                        switch urlError.code {
                            case .notConnectedToInternet, .cannotConnectToHost, .timedOut, .networkConnectionLost:
                                return .noInternet
                            case .cannotFindHost, .dnsLookupFailed:
                                return .invalidURL
                            default:
                                return .networkError(urlError)
                        }
                    }
                    return .unknown
                default:
                    return .unknown
            }
        }
        
        if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
                case .notConnectedToInternet, .cannotConnectToHost, .timedOut, .networkConnectionLost:
                    return .noInternet
                case .cannotFindHost, .dnsLookupFailed:
                    return .invalidURL
                default:
                    return .networkError(urlError)
            }
        }
        
        return .unknown
    }
    
}
