//
//  APIError 2.swift
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
        }
    }
    
    // Добавляем статический метод `from` для преобразования Error в APIError
    static func from(_ error: Error) -> APIError {
        // Если ошибка уже является APIError, возвращаем её напрямую
        if let apiError = error as? APIError {
            return apiError
        }
        
        // Если ошибка является AFError (из Alamofire/Moya)
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
        
        // Если ошибка - это DecodingError
        if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
        }
        
        // Если ошибка - это URLError напрямую
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
        
        // В остальных случаях возвращаем unknown
        return .unknown
    }
}