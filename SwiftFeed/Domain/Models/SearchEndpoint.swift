//
//  SearchEndpoint.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

// Only the repositories endpoint is being used. The other cases were added as an
// example that can be followed in the same style as the list of endpoints grows.

enum SearchEndpoint {
    case repositories(matching: String?, sort: String?, order: String?, pagination: Pagination?)
    case commits
    case users
}

extension SearchEndpoint: Endpoint {
    
    private enum QueryKey {
        static let query = "q"
        static let sort = "sort"
        static let order = "order"
        static let pageIndex = "page"
        static let resultsPerPage = "per_page"
    }
    
    var path: String {
        switch self {
        case .repositories:
            return "/search/repositories"
        case .commits:
            return "/search/commits"
        case .users:
            return "/search/users"
        }
    }
    
    var parameters: [String : String] {
        switch self {
        case .repositories(let query, let sort, let order, let pagination):
            return [
                QueryKey.query: query,
                QueryKey.sort: sort,
                QueryKey.order: order,
                QueryKey.pageIndex: pagination?.pageIndex,
                QueryKey.resultsPerPage: pagination?.itemsPerPage].compactMapValues {$0}
        case .commits: return [:]
        case .users: return [:]
        }
    }
    
    var method: HTTPMethod {
        .get
    }
}
