//
//  Untitled.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 15.03.2025.
//
    

import Foundation
import Moya

enum APIError: LocalizedError {
    
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int)
    case invalidURL
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .networkError(let error):
                return "Error: \(error.localizedDescription)"
            case .decodingError(let error):
                return "Decoding Error: \(error.localizedDescription)"
            case .serverError(let statusCode):
                return "Server Error (Code: \(statusCode))"
            case .invalidURL:
                return "Invalid URL provided"
            case .unknown:
                return "An unknown error occurred"
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
                        return .networkError(urlError)
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
            return .networkError(urlError)
        }
        return .unknown
    }
    
}
