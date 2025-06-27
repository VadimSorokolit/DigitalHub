//
//  APIError.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 17.03.2025.
//
    
import Foundation
import Moya

enum APIError: LocalizedError {
    
    case noInternet
    case network(Error)
    case decoding(Error)
    case emptyProductName
    case serverStatusCode(_ code: Int)
    case invalidURL
    case storage(Error)
    case unknown
    case deleteFailed
    case notFound
    case createProductFailed
    
    var errorDescription: String? {
        switch self {
            case .noInternet:
                return "No internet connection"
            case .network(let err):
                return "Network Error: \(err.localizedDescription)"
            case .decoding(let err):
                return "Decoding Error: \(err.localizedDescription)"
            case .serverStatusCode(let code):
                return "Server Error (Code: \(code))"
            case .invalidURL:
                return "Invalid URL provided"
            case .unknown:
                return "An unknown error occurred"
            case .emptyProductName:
                return "Error: Product name cannot be empty"
            case .storage(let error):
                return "Storage error: \(error.localizedDescription)"
            case .notFound:
                return "Error: Product not found"
            case .createProductFailed:
                return "Error: Failed to create product"
            case .deleteFailed:
                return "Error: Failed to delete product"
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
                                return .serverStatusCode(code)
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
                                return .network(urlError)
                        }
                    }
                    return .unknown
                default:
                    return .unknown
            }
        }
        
        if let decodingError = error as? DecodingError {
            return .decoding(decodingError)
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
                case .notConnectedToInternet, .cannotConnectToHost, .timedOut, .networkConnectionLost:
                    return .noInternet
                case .cannotFindHost, .dnsLookupFailed:
                    return .invalidURL
                default:
                    return .network(urlError)
            }
        }
        
        return .unknown
    }
    
}
