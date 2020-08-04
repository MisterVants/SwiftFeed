//
//  NetworkError.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

import Foundation

enum NetworkError: Error {
    case dataTaskError(Error)
    case dataTaskCancelled
    case noResponse
    case badStatusCode(Int)
    case responseDataNil
    case jsonDecodeFailed(Error, Data)
}
