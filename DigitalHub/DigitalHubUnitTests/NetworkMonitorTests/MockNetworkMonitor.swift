//
//  MockNetworkMonitor.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.06.2025.
//

import Foundation
import Network
import Combine
@testable import DigitalHub

final class MockNetworkMonitor: NetworkMonitoring {
    
    // MARK: - Properties
    
    var isConnected: Bool
    var isConnectedSubject = CurrentValueSubject<Bool, Never>(false)

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initializer
    
    init(isConnected: Bool = false) {
        self.isConnected = isConnected
        isConnectedSubject.send(isConnected)
    }
    
    // MARK: - Methods
    
    func setConnected(_ connected: Bool) {
        self.isConnected = connected
        isConnectedSubject.send(connected)
    }
}
