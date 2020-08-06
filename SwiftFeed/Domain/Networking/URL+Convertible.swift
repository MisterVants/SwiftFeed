//
//  URL+Convertible.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

protocol URLConvertible {
    func asURL() throws -> URL
}

extension URLComponents: URLConvertible {
    func asURL() throws -> URL {
        guard let url = self.url else { throw NetworkError.invalidURL(url: self) }
        return url
    }
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw NetworkError.invalidURL(url: self) }
        return url
    }
}
