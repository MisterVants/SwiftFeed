//
//  Pagination.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

/**
 A structure specifying the size and offset of a page of results for APIs that require pagination.
 */
struct Pagination {
    /**
     The offset index for the requested page of results.
     */
    let pageIndex: String
    
    /**
     The amount of items to include in a single page of results.
     */
    let itemsPerPage: String
    
    init(index: Int, itemsPerPage: Int) {
        self.pageIndex = String(index)
        self.itemsPerPage = String(itemsPerPage)
    }
}
