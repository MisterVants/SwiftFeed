//
//  PageFeed.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import Foundation

protocol PageFeedDelegate: AnyObject {
    
    /**
     Tells the delegate that a new page of items was loaded and added into the feed.
     
     - parameters:
        - feed: The feed object that is informing the delegate about an update.
        - indexPaths: The index paths values for all items that were added to the feed.
        - pageIndex: The index number for the page of results that was loaded.
     */
    func pageFeed(_ feed: PageFeed, didLoadNewItemsAt indexPaths: [IndexPath], onPage pageIndex: Int)
    
    /**
     Tells the delegate that an error happened while loading a new page of items.
     
     - parameters:
        - feed: The feed object that is informing the delegate about an error.
        - error: The error object containing the reason why new items could not be loaded.
     */
    func pageFeed(_ feed: PageFeed, didFailLoadingWithError error: Error)
}

class PageFeed {
    
    weak var delegate: PageFeedDelegate?
    
    private(set) var items: [Repository] = []
    
    var programmingLanguage: String = SearchAPI.defaultLanguageToQuery
    private(set) var resultsPerPage: Int
    private(set) var currentPage: Int
    var nextPage: Int { currentPage + 1 }
    
    private let searchAPI: SearchService
    private let callbackQueue: DispatchQueue
    private var cancellable: Cancellable?
    
    init(
        resultsPerPage: Int = SearchAPI.defaultPageSize,
        searchAPI: SearchService = GitHubClient(),
        delegateQueue: DispatchQueue = .main)
    {
        self.currentPage = 0
        self.resultsPerPage = resultsPerPage
        self.searchAPI = searchAPI
        self.callbackQueue = delegateQueue
    }
    
    func loadNextPage(resetPagination: Bool = false) {
        
        if resetPagination {
            cancellable?.cancel()
        } else {
            guard cancellable == nil else { return }
        }
        let targetPageIndex = resetPagination ? 1 : nextPage
        
        cancellable = searchAPI.getRepositories(
            matching: SearchAPI.languageQuery(for: programmingLanguage),
            sortBy: .numberOfStars,
            order: .descending,
            page: targetPageIndex,
            resultsPerPage: resultsPerPage)
        { [weak self] result in
            guard let self = self else { return }
            self.callbackQueue.async {
                self.cancellable = nil
                do {
                    let newItems = try result.get()
                    if resetPagination {
                        self.items.removeAll(keepingCapacity: true)
                    }
                    self.items.append(contentsOf: newItems)
                    self.currentPage = targetPageIndex
                    let newIndices = IndexPath.computeIndexPaths(ofAppended: newItems, in: self.items)
                    self.delegate?.pageFeed(self, didLoadNewItemsAt: newIndices, onPage: targetPageIndex)
                } catch {
                    self.delegate?.pageFeed(self, didFailLoadingWithError: error)
                }
            }
        }
    }
}

fileprivate extension IndexPath {
    static func computeIndexPaths<T>(ofAppended appendedItems: T, in allItems: T) -> [IndexPath] where T: Collection {
        let startIndex = allItems.count - appendedItems.count
        let endIndex = startIndex + appendedItems.count
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        return indexPaths
    }
}
