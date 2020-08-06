//
//  PageFeedSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

// MARK: Test Doubles

fileprivate final class PageFeedDelegateMock: PageFeedDelegate {
    
    var completion: (() -> Void)?
    var didSucceed = false
    var didFail = false
    
    var lastReceivedPageIndex = -1
    var lastReceivedIndexPaths: [IndexPath] = []
    
    func pageFeed(_ feed: PageFeed, didLoadNewItemsAt indexPaths: [IndexPath], onPage pageIndex: Int) {
        didSucceed = true
        lastReceivedPageIndex = pageIndex
        lastReceivedIndexPaths = indexPaths
        completion?()
    }
    
    func pageFeed(_ feed: PageFeed, didFailLoadingWithError error: Error) {
        didFail = true
        completion?()
    }
}

fileprivate class SimpleCancellable: Cancellable {
    private(set) var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}

fileprivate final class SearchServiceMock: SearchService {
    
    var completeAutomatically: Bool = true
    var shouldFail: Bool = false
    
    private(set) var cachedCancellable: SimpleCancellable?
    private(set) var callsReceived: Int = 0
    private(set) var lastPageRequested: Int = -1
    
    func getRepositories(
        matching query: String,
        sortBy sortingRule: SearchAPI.Sorting.Repository?,
        order: SearchAPI.Ordering?,
        page: Int,
        resultsPerPage: Int,
        completion: @escaping (Result<[Repository], Error>) -> Void
    ) -> Cancellable?
    {
        callsReceived += 1
        lastPageRequested = page
        if completeAutomatically {
            let result = makeResult()
            DispatchQueue.global().async {
                completion(result)
            }
        }
        let cancelToken = SimpleCancellable()
        cachedCancellable = cancelToken
        return cancelToken
    }
    
    private func makeResult() -> Result<[Repository], Error> {
        shouldFail ?
            .failure(NSError.wildcard) :
            Result { try TestDataLoader.loadSearchRepositoriesData().items }
    }
}

// MARK: Test Spec

final class PageFeedSpec: QuickSpec {
    
    override func spec() {
        
        var feed: PageFeed!
        var testDelegate: PageFeedDelegateMock!
        
        describe("page feed") {
            
            beforeEach {
                testDelegate = PageFeedDelegateMock()
            }
            
            context("initialization") {
                it("starts on a fresh state") {
                    feed = PageFeed(searchAPI: SearchServiceMock())
                    expect(feed.items).to(beEmpty())
                    expect(feed.nextPage).to(equal(1))
                }
            }
            
            context("on load next page") {
                
                // MARK: Success Tests
                
                context("success callback") {
                    
                    beforeEach {
                        feed = PageFeed(searchAPI: SearchServiceMock())
                        feed.delegate = testDelegate
                    }
                    
                    it("calls delegate load success") {
                        waitUntil { done in
                            testDelegate.completion = {
                                expect(testDelegate.didSucceed).to(beTrue())
                                expect(feed.items).toNot(beEmpty())
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                    
                    it("increments pagination index") {
                        let indexToFetch = feed.nextPage
                        waitUntil { done in
                            testDelegate.completion = {
                                expect(feed.currentPage).to(equal(indexToFetch))
                                expect(testDelegate.lastReceivedPageIndex).to(equal(indexToFetch))
                                expect(testDelegate.lastReceivedIndexPaths).to(containElementSatisfying({ $0.row == feed.items.count - 1 }))
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                }
                
                // MARK: Failure Tests
                
                context("failure callback") {
                    
                    beforeEach {
                        let apiMock = SearchServiceMock()
                        apiMock.shouldFail = true
                        feed = PageFeed(searchAPI: apiMock)
                        feed.delegate = testDelegate
                    }
                    
                    it("calls delegate load failure") {
                        waitUntil { done in
                            testDelegate.completion = {
                                expect(testDelegate.didFail).to(beTrue())
                                expect(feed.items).to(beEmpty())
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                    
                    it("does not modify pagination") {
                        let initialPageIndex = feed.currentPage
                        waitUntil { done in
                            testDelegate.completion = {
                                expect(feed.currentPage).to(equal(initialPageIndex))
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                }
                
                // MARK: Pagination Tests
                
                context("pagination") {
                    
                    var apiMock: SearchServiceMock!
                    
                    beforeEach {
                        apiMock = SearchServiceMock()
                        feed = PageFeed(searchAPI: apiMock, delegateQueue: DispatchQueue(label: "test-queue", qos: .background))
                        feed.delegate = testDelegate
                        
                        // Load some pages before testing refresh
                        (1...5).forEach { _ in
                            let semaphore = DispatchSemaphore(value: 0)
                            testDelegate.completion = { semaphore.signal() }
                            feed.loadNextPage()
                            semaphore.wait()
                        }
                    }
                    
                    context("next page") {
                        
                        it("correctly computes new index paths") {
                            let initialCount = feed.items.count
                            waitUntil { done in
                                testDelegate.completion = {
                                    let receivedIndexPaths = testDelegate.lastReceivedIndexPaths
                                    expect(receivedIndexPaths).to(haveCount(feed.resultsPerPage))
                                    expect(receivedIndexPaths).to(allPass({ $0!.row > initialCount - 1 }))
                                    expect(receivedIndexPaths).to(containElementSatisfying({ $0.row == feed.items.count - 1 }))
                                    done()
                                }
                                feed.loadNextPage()
                            }
                        }
                    }
                    
                    context("refresh") {
                        
                        it("resets feed on success") {
                            let initialItemCount = feed.items.count
                            
                            waitUntil { done in
                                testDelegate.completion = {
                                    expect(feed.currentPage).to(equal(1))
                                    expect(feed.items.count).to(beLessThan(initialItemCount))
                                    expect(testDelegate.lastReceivedPageIndex).to(equal(1))
                                    expect(testDelegate.lastReceivedIndexPaths).to(containElementSatisfying({ $0.row == 0 }))
                                    done()
                                }
                                feed.loadNextPage(resetPagination: true)
                                expect(apiMock.lastPageRequested).to(equal(1))
                            }
                        }
                        
                        it("remains unchanged on failure") {
                            apiMock.shouldFail = true
                            let initialItemCount = feed.items.count
                            let initialPageIndex = feed.currentPage
                            
                            waitUntil { done in
                                testDelegate.completion = {
                                    expect(feed.currentPage).to(equal(initialPageIndex))
                                    expect(feed.items.count).to(equal(initialItemCount))
                                    done()
                                }
                                feed.loadNextPage(resetPagination: true)
                                expect(apiMock.lastPageRequested).to(equal(1))
                            }
                        }
                        
                        it("cancels any ongoing request") {
                            apiMock.completeAutomatically = false
                            
                            feed.loadNextPage()
                            let cancellable = apiMock.cachedCancellable
                            feed.loadNextPage(resetPagination: true)
                            
                            expect(cancellable?.isCancelled).to(beTrue())
                        }
                    }
                }
                
                // MARK: Request Management Tests
                
                context("load request management") {
                    
                    var apiMock: SearchServiceMock!
                    
                    beforeEach {
                        apiMock = SearchServiceMock()
                        feed = PageFeed(searchAPI: apiMock)
                        feed.delegate = testDelegate
                    }
                    
                    it("drops redundant calls while running a request") {
                        apiMock.completeAutomatically = false
                        
                        (1...10).forEach { _ in feed.loadNextPage() }
                        expect(apiMock.callsReceived).to(equal(1))
                    }
                    
                    it("allows load request after success") {
                        waitUntil { done in
                            testDelegate.completion = {
                                apiMock.completeAutomatically = false // Disable completion to prevent a recursive callback
                                feed.loadNextPage()
                                expect(apiMock.callsReceived).to(beGreaterThan(1))
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                    
                    it("allows load request after failure") {
                        apiMock.shouldFail = true
                        waitUntil { done in
                            testDelegate.completion = {
                                apiMock.completeAutomatically = false // Disable completion to prevent a recursive callback (again)
                                feed.loadNextPage()
                                expect(apiMock.callsReceived).to(beGreaterThan(1))
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                }
            }
        }
    }
}
