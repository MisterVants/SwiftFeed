//
//  UIFont+Style.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import UIKit

// A utility extension to manage custom fonts for the App.
extension UIFont {
    
    enum CustomFont: String {
        case montserratRegular = "Montserrat-Regular"
        case montserratBold = "Montserrat-Bold"
    }
    
    static func preferredCustomFont(
        for textStyle: UIFont.TextStyle,
        weight: Weight,
        maximumSize: CGFloat = CGFloat.infinity) -> UIFont
    {
        let preferredFont = selectFont(for: weight)
        return customFont(preferredFont, textStyle: textStyle, maximumSize: maximumSize)
    }
    
    static func customFont(
        _ customFont: CustomFont,
        textStyle: UIFont.TextStyle,
        maximumSize: CGFloat = CGFloat.infinity) -> UIFont
    {
        let fontName = customFont.rawValue
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        guard let font = UIFont(name: fontName, size: descriptor.pointSize) else { fatalError("Font file not found in bundle for font \(fontName)") }
        let scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font, maximumPointSize: maximumSize)
        return scaledFont
    }
    
    private static func selectFont(for weight: Weight) -> CustomFont {
        switch weight {
        case .bold: return CustomFont.montserratBold
        default: return CustomFont.montserratRegular
        }
    }
}
