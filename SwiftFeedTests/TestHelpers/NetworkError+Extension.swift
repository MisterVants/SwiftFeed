//
//  NetworkError+Extension.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

import Foundation
@testable import SwiftFeed

extension NSError {
    static var wildcard: Error {
        NSError(domain: "test-error", code: -1, userInfo: nil)
    }
}

extension NetworkError {
    
    var isBadStatusCodeError: Bool {
        if case .badStatusCode = self { return true }
        return false
    }
    
    var isJsonDecodeError: Bool {
        if case .jsonDecodeFailed = self { return true }
        return false
    }
}
