//
//  TimeTraveler.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

class TimeTraveler {
    
    private var date = Date()
    
    func travel(by timeInterval: TimeInterval) {
        date = date.addingTimeInterval(timeInterval)
    }
    
    func getDate() -> Date {
        return date
    }
}
