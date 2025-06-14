//
//  Array+chunked.swift
//  DigitalHub
//
//  Created by Vadim Sorokolit on 14.06.2025.
//

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        
        return stride(from: 0, to: count, by: size).map { start in
            Array(self[start..<Swift.min(start + size, count)])
        }
    }
    
}
