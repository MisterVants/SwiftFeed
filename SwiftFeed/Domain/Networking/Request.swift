//
//  Request.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

struct Request {
    let baseURL: URLConvertible
    let endpoint: Endpoint
}

extension Request: URLConvertible, URLRequestConvertible {
    
    func asURL() throws -> URL {
        guard var components = URLComponents(url: try baseURL.asURL(), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL(url: baseURL)
        }
        components.path = endpoint.path
        if !endpoint.parameters.isEmpty {
            components.queryItems = endpoint.parameters.map { URLQueryItem(name: $0, value: $1) }
        }
        return try components.asURL()
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: try self.asURL())
        request.httpMethod = endpoint.method.rawValue
        return request
    }
}
