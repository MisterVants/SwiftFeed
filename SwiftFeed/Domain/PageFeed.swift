//
//  PageFeed.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import Foundation

protocol PageFeedDelegate: AnyObject {
    func pageFeed(_ feed: PageFeed, didLoadNewItemsAt indexPaths: [IndexPath], onPage pageIndex: Int)
    func pageFeed(_ feed: PageFeed, didFailLoadingWithError error: Error)
}

class PageFeed {
    
    static let maximumResultsPerPage = 100
    static let defaultResultsPerPage = 30
    
    weak var delegate: PageFeedDelegate?
    
    private(set) var items: [Repository] = []
    private(set) var currentPage: Int
    var nextPage: Int { currentPage + 1 }
    
    private let searchAPI: SearchAPI
    private let callbackQueue: DispatchQueue
    
    private var cancellable: Cancellable?
    
    init(searchAPI: SearchAPI = GitHubSearch(), delegateQueue: DispatchQueue = .main) {
        self.currentPage = 0
        self.searchAPI = searchAPI
        self.callbackQueue = delegateQueue
    }
    
    func loadNextPage(resetPagination: Bool = false) {
        
        if resetPagination {
            cancellable?.cancel()
        } else {
            guard cancellable == nil else { return }
        }
        
        cancellable = searchAPI.getRepositories { result in
            switch result {
            case .success(let repositories):
                self.callbackQueue.async {
                    let currentPage = self.nextPage
                    self.cancellable = nil
                    if resetPagination {
                        self.currentPage = 1
                        self.items.removeAll(keepingCapacity: true)
                        self.items.append(contentsOf: repositories)
                        self.delegate?.pageFeed(self, didLoadNewItemsAt: [], onPage: currentPage) // TODO: Add tests
                    } else {
                        self.currentPage = currentPage
                        self.items.append(contentsOf: repositories)
                        self.delegate?.pageFeed(self, didLoadNewItemsAt: [], onPage: currentPage) // TODO: Add tests
                    }
                }
            case .failure(let error):
                self.callbackQueue.async {
                    self.cancellable = nil
                    self.delegate?.pageFeed(self, didFailLoadingWithError: error)
                }
            }
        }
    }
}
