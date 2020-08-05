//
//  UIImage+Assets.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import UIKit

// MARK: - Strong typed image assets

extension UIImage {
    
    enum ImageAsset: String, CaseIterable {
        case defaultAvatar = "placeholder-avatar"
        case iconStar = "octicon-star"
    }
    
    convenience init?(asset: ImageAsset, in bundle: Bundle? = nil, compatibleWith traitCollection: UITraitCollection? = nil) {
        self.init(named: asset.rawValue, in: bundle, compatibleWith: traitCollection)
    }
}
