//
//  NetworkMonitorTests.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 27.06.2025.
//
    
import XCTest
import Combine
@testable import DigitalHub

final class NetworkMonitorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Test Methods
    
    func test_isConnectedPublishesChange() {
        let mockMonitor = MockNetworkMonitor(isConnected: false)
        var results: [Bool] = []
        
        mockMonitor.isConnectedPublisher
            .sink { value in
                results.append(value)
            }
            .store(in: &self.subscriptions)
        
        mockMonitor.setConnected(true)
        mockMonitor.setConnected(false)
        
        XCTAssertEqual(results, [false, true, false])
    }
    
}
