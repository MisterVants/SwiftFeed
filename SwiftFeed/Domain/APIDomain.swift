//
//  APIDomain.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

typealias URLScheme = String

protocol APIDomain: URLConvertible {
    var scheme: URLScheme { get }
    var host: String { get }
}

extension APIDomain {
    func asURL() throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        return try components.asURL()
    }
}

struct GitHubDomain: APIDomain {
    
    let scheme: URLScheme
    let host: String
    
    var urlString: String? {
        try? self.asURL().absoluteString
    }
    
    static func resolve() -> APIDomain {
        GitHubDomain(
            scheme: Environment.urlScheme ?? "",
            host: Environment.apiHost ?? "")
    }
}
