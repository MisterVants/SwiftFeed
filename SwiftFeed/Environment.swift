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
    
    /*
     NOTE: In a real-world scenarion, it would be better to pull this data from a xcconfig file to
     allow control over different build configurations to point to different API environments,
     like production and development, and avoid data problems in critical environments.
     */
    static var urlScheme: String? {
        "https"
    }
    
    static var apiHost: String? {
        "api.github.com"
    }
}
