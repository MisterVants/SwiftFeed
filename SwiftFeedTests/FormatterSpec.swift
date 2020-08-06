//
//  FormatterSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

final class FormatterSpec: QuickSpec {
    
    override func spec() {
        
        describe("number formatter") {
            
            it("correctly formats integers into text with thousands separator") {
                let formatter = NumberFormatter.customDefault
                expect(formatter.string(from: 0)).to(equal("0"))
                expect(formatter.string(from: 999)).to(equal("999"))
                expect(formatter.string(from: 9999)).to(equal("9.999"))
                expect(formatter.string(from: 9999999)).to(equal("9.999.999"))
            }
        }
    }
}
