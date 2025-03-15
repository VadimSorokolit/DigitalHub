//
//  DigitalProduct.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 13.03.2025.
//
    

import Foundation
import SwiftData

@Model
final class DigitalProduct {
    
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
    
}
