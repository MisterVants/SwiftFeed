//
//  SearchAPI.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

enum SearchAPI {
    
    typealias Endpoint = SearchEndpoint
    
    static let maximumPageSize = 100
    static let defaultPageSize = 30
    static let defaultLanguageToQuery = "swift"
    
    static func languageQuery(for language: String) -> String {
        "language:\(language)"
    }
    
    enum Sorting {
        enum Repository: String, CaseIterable {
            case numberOfStars = "stars"
            case numberOfForks = "forks"
            case issues = "help-wanted-issues"
            case recency = "updated"
        }
        
        enum Commit: String, CaseIterable {
            case authorDate = "author-date"
            case committerDate = "committer-date"
        }
        
        enum User: String, CaseIterable {
            case numberOfFollowers = "followers"
            case numberOfRepositories = "repositories"
            case dateJoined = "joined"
        }
    }
    
    enum Ordering: String, CaseIterable {
        case descending = "desc"
        case ascending = "asc"
    }
}
