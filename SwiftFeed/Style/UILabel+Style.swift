//
//  UILabel+Style.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import UIKit

extension UILabel {
    
    // Utility method to provide adaptive text labels matching a typographic style.
    static func makeWithStyle(
        _ textStyle: UIFont.TextStyle,
        weight: UIFont.Weight = .regular,
        maximumSize: CGFloat = CGFloat.infinity) -> UILabel
    {
        let label = UILabel()
        label.font = UIFont.preferredCustomFont(for: textStyle, weight: weight, maximumSize: maximumSize)
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    func lineLimit(_ number: Int) -> Self {
        numberOfLines = number
        return self
    }
}
