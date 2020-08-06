//
//  SearchDTO.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

/**
 The root object that a search query on GitHub API returns.
 */
struct SearchDTO<Item>: Codable where Item: Codable {
    
    /**
     The number of total results matching the search query.
     */
    let totalResults: Int
    
    /**
     A boolean indicating if the query returned before finishing.
     
     [From GitHub API Docs]: If the query exceeds the time limit, the API returns the matches that were already found prior to the timeout, and the response has the `incomplete_results` property set to true.
     
     [From GitHub API Docs]: (https://developer.github.com/v3/search/#timeouts-and-incomplete-results)
     */
    let incompleteResults: Bool
    
    /**
     An array containing the query results.
     */
    let items: [Item]
    
    private enum CodingKeys: String, CodingKey {
        case totalResults = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
