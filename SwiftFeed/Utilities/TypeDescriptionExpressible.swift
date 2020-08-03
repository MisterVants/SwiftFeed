//
//  TypeDescriptionExpressible.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

protocol TypeDescriptionExpressible {
    static var typeDescription: String { get }
    var typeDescription: String { get }
}

extension TypeDescriptionExpressible {
    static var typeDescription: String {
        return String(describing: self)
    }
    
    var typeDescription: String {
        return type(of: self).typeDescription
    }
}

extension UIView: TypeDescriptionExpressible {}
