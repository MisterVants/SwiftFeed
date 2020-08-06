//
//  Localized.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

/**
 A namespace for strong-typed strings, organized in a way that can leverage the use of automatic code generation tools to build the strings from a Localized.strings file.
 */
enum Localized {

    static let navigationTitle = Localized.string(key: "navbar.title")
    static let loading = Localized.string(key: "loading")
    
    enum Error {
        static let title = Localized.string(key: "error.title")
        static let message = Localized.string(key: "error.message")
        static let action = Localized.string(key: "error.action")
    }
}

extension Localized {
    private static func string(key: String, value: String? = nil, table: String? = nil, _ args: CVarArg...) -> String {
        let localizedString = Bundle.main.localizedString(forKey: key, value: value, table: table)
        return String(format: localizedString, locale: Locale.current, arguments: args)
    }
}
