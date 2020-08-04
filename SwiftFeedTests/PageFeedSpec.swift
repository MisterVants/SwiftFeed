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
    
    func pageFeed(_ feed: PageFeed, didLoadNewItemsAt indexPaths: [IndexPath], onPage pageIndex: Int) {
        didSucceed = true
        completion?()
    }
    
    func pageFeed(_ feed: PageFeed, didFailLoadingWithError error: Error) {
        didFail = true
        completion?()
    }
}

fileprivate final class SearchAPIMock: SearchAPI {
    
    var completeAutomatically: Bool = true
    var shouldFail: Bool = false
    
    private(set) var callsReceived: Int = 0
    private(set) var cachedCancellable: Cancellable?
    
    func getRepositories(completion: @escaping (Result<[Repository], Error>) -> Void) -> Cancellable {
        callsReceived += 1
        
        if completeAutomatically {
            let result = makeResult()
            DispatchQueue.global().async {
                completion(result)
            }
        }
        
        let cancelToken = Cancellable()
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
                    feed = PageFeed(searchAPI: SearchAPIMock())
                    expect(feed.items).to(beEmpty())
                    expect(feed.nextPage).to(equal(1))
                }
            }
            
            context("on load next page") {
                
                // MARK: Success Tests
                
                context("success callback") {
                    
                    beforeEach {
                        feed = PageFeed(searchAPI: SearchAPIMock())
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
                                done()
                            }
                            feed.loadNextPage()
                        }
                    }
                }
                
                // MARK: Failure Tests
                
                context("failure callback") {
                    
                    beforeEach {
                        let apiMock = SearchAPIMock()
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
                
                // MARK: Pagination Reset Tests
                
                context("reseting pagination") {
                    
                    var apiMock: SearchAPIMock!
                    
                    beforeEach {
                        apiMock = SearchAPIMock()
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
                    
                    it("refreshes feed on success") {
                        let initialItemCount = feed.items.count
                        
                        waitUntil { done in
                            testDelegate.completion = {
                                expect(feed.currentPage).to(equal(1))
                                expect(feed.items.count).to(beLessThan(initialItemCount))
                                done()
                            }
                            feed.loadNextPage(resetPagination: true)
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
                
                // MARK: Request Management Tests
                
                context("load request management") {
                    
                    var apiMock: SearchAPIMock!
                    
                    beforeEach {
                        apiMock = SearchAPIMock()
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
