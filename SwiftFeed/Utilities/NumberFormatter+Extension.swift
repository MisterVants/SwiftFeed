//
//  NumberFormatter+Extension.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

extension NumberFormatter {
    
    /// A custom number formatter preset to format numbers following the mask: `0.000.000`.
    static let customDefault: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter
    }()
    
    func string(from integer: Int) -> String? {
        return string(from: NSNumber(value: integer))
    }
}
