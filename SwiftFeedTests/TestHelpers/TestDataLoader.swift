//
//  TestDataLoader.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import Foundation
@testable import SwiftFeed

final class TestDataLoader {
    
    enum Error: Swift.Error {
        case fileNotFount(_ file: String, _ type: String)
    }
    
    static func loadSearchRepositoriesData() throws -> SearchDTO<Repository> {
        try load(SearchDTO.self, fromFile: "searchRepositoriesStub")
    }
    
    private static func load<T: Decodable>(_ type: T.Type, fromFile file: String, fileType: String = "json") throws -> T {
        guard let path = Bundle(for: Self.self).path(forResource: file, ofType: fileType) else {
            throw Error.fileNotFount(file, fileType)
        }
        return try decode(T.self, fromFileAt: path)
    }
    
    private static func decode<T: Decodable>(_ type: T.Type, fromFileAt path: String) throws -> T {
        let url = URL(fileURLWithPath: path)
        let fileData = try Data(contentsOf: url, options: .uncached)
        return try JSONDecoder().decode(T.self, from: fileData)
    }
}
