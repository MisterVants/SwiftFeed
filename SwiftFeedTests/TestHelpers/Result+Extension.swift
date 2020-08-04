//
//  Result+Extension.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

extension Result {
    
    var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}

