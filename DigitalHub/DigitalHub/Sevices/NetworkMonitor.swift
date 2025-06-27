//
//  Untitled.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 17.06.2025.
//
    
import Foundation
import Network
import Combine

protocol NetworkMonitoring {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

final class NetworkMonitor: ObservableObject, NetworkMonitoring {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool = false

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue.global()

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }

    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor

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
