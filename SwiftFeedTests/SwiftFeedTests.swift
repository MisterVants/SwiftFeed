//
//  SwiftFeedTests.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import XCTest
@testable import SwiftFeed

class SwiftFeedTests: XCTestCase {
    
    func testExample() throws {
        let searchStub = try TestDataLoader.loadSearchRepositoriesData()
        XCTAssertFalse(searchStub.items.isEmpty)
    }
}
