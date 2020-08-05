//
//  Environment.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

public enum Environment {
    
    static var bundleIdentifier: String {
        guard let id = Bundle.main.bundleIdentifier else { fatalError("Bundle identifier not found") }
        return id
    }
    
    static var urlScheme: String? {
        "https"
    }
    
    static var apiHost: String? {
        "api.github.com"
    }
}
