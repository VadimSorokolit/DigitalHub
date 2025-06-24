//
//  Untitled.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 17.06.2025.
//
    
import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue.global()
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
