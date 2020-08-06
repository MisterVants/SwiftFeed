//
//  RateLimitHandlerSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

final class RateLimitHandlerSpec: QuickSpec {
    
    override func spec() {
        
        var handler: RateLimitHandler!
        
        let testLimit = 5
        let resetInterval: TimeInterval = 60
        
        beforeEach {
            handler = RateLimitHandler(rateLimit: testLimit)
        }
        
        describe("api rate limits handler") {
            
            it("starts with provided rate limits") {
                expect(handler.rateLimit).to(equal(testLimit))
                expect(handler.remainingLimit).to(equal(testLimit))
                expect(handler.borrowedTokens).to(equal(0))
                expect(handler.resetDate).to(beLessThan(Date()))
            }
            
            it("updates rate limit data when new data is received") {
                let newLimit = RateLimit(limit: 100, remaining: 99, resetIntervalInSeconds: resetInterval)
                handler.updateRateLimits(newLimit)
                expect(handler.rateLimit).to(equal(newLimit.limit))
                expect(handler.remainingLimit).to(equal(newLimit.remaining))
                expect(handler.resetDate).to(beGreaterThan(Date()))
            }
            
            context("limit definition") {
                
                it("is reached when limits are updated with zero remaining") {
                    let newLimit = RateLimit(limit: testLimit, remaining: 0, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    expect(handler.hasReachedLimit).to(beTrue())
                }
                
                it("is reached when maximum tokens are borrowed") {
                    (1...testLimit).forEach { _ in
                        if !handler.holdRequestToken() { fail("request tokens should be successfully borrowed until limit") }
                    }
                    expect(handler.hasReachedLimit).to(beTrue())
                }
                
                it("is reached combining token borrowing and limit updating") {
                    let newLimit = RateLimit(limit: testLimit, remaining: 1, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    _ = handler.holdRequestToken()
                    expect(handler.hasReachedLimit).to(beTrue())
                }
            }
            
            context("token borrowing") {
                
                it("allow tokens if rate limit has not yet reached limit") {
                    let newLimit = RateLimit(limit: testLimit, remaining: 1, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    expect(handler.holdRequestToken()).to(beTrue())
                }
                
                it("deny tokens if too much tokens are borrowed") {
                    (1...testLimit).forEach { _ in
                        if !handler.holdRequestToken() { fail("request tokens should be successfully borrowed until limit") }
                    }
                    expect(handler.remainingLimit).to(beGreaterThan(0))
                    expect(handler.holdRequestToken()).to(beFalse())
                }
                
                it("deny tokens if rate limit is reached and reset window is not expired") {
                    let newLimit = RateLimit(limit: testLimit, remaining: 0, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    expect(handler.holdRequestToken()).to(beFalse())
                }
            }
            
            context("token consuming") {
                
                it("cannot consume token if no tokens are borrowed") {
                    expect(handler.consumeRequestToken()).to(beFalse())
                }
                
                it("consumes token if a token is borrowed") {
                    expect(handler.holdRequestToken()).to(beTrue())
                    expect(handler.consumeRequestToken()).to(beTrue())
                }
                
                it("allows request token to be borrowed after a token is consumed") {
                    (1...testLimit).forEach { _ in
                        if !handler.holdRequestToken() { fail("request tokens should be successfully borrowed until limit") }
                    }
                    expect(handler.hasReachedLimit).to(beTrue())
                    
                    handler.consumeRequestToken()
                    expect(handler.hasReachedLimit).to(beFalse())
                    expect(handler.holdRequestToken()).to(beTrue())
                }
            }
            
            context("reset window expiration") {
                
                it("allow tokens and fallback to default limits") {
                    let updatedLimit = testLimit + 10
                    let timeTraveler = TimeTraveler()
                    handler = RateLimitHandler(rateLimit: testLimit, dateGenerator: timeTraveler.getDate)
                    
                    let newLimit = RateLimit(limit: updatedLimit, remaining: 0, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    timeTraveler.travel(by: resetInterval + 1)
                    
                    expect(handler.rateLimit).to(equal(updatedLimit))
                    expect(handler.remainingLimit).to(equal(0))
                    
                    expect(handler.holdRequestToken()).to(beTrue())
                    expect(handler.rateLimit).to(equal(testLimit))
                    expect(handler.remainingLimit).to(beGreaterThan(0))
                }
                
                it("allow tokens for remaining reset threshold") {
                    let timeTraveler = TimeTraveler()
                    handler = RateLimitHandler(rateLimit: testLimit, dateGenerator: timeTraveler.getDate)
                    
                    (1...testLimit - 1).forEach { _ in
                        if !handler.holdRequestToken() { fail("request tokens should be successfully borrowed until limit") }
                    }
                    let newLimit = RateLimit(limit: testLimit, remaining: testLimit - 1, resetIntervalInSeconds: resetInterval)
                    handler.updateRateLimits(newLimit)
                    
                    expect(handler.holdRequestToken()).to(beFalse())
                    timeTraveler.travel(by: resetInterval + 1)
                    
                    expect(handler.holdRequestToken()).to(beTrue())
                    expect(handler.hasReachedLimit).to(beTrue())
                }
            }
        }
    }
}
