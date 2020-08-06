//
//  ImageAssetSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

final class ImageAssetSpec: QuickSpec {
    
    override func spec() {
        
        let targetBundle = Bundle(identifier: Environment.bundleIdentifier)
        
        describe("image assets") {
            it("file should exist in bundle for all images") {
                for imageAsset in UIImage.ImageAsset.allCases {
                    let image = UIImage(asset: imageAsset, in: targetBundle, compatibleWith: nil)
                    expect(image).toNot(beNil())
                }
            }
        }
    }
}
