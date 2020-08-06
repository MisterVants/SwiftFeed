//
//  RateLimitHandler.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

/**
 A small system to handle rate limits from the API.
 
 Requests that target an endpoint that is rate-limited should hold a token before proceeding and return the token after responding.
 If the token is denied, the API has reached the rate limit and the request should return immediately.
 */
class RateLimitHandler {
    
    private let dateGenerator: () -> Date
    private let defaultRateLimit: Int
    
    /// The total number of calls allowed by the current rate limits.
    private(set) var rateLimit: Int
    
    /// The number of remaining calls allowed by the current rate limits.
    private(set) var remainingLimit: Int
    
    /// The number of borrowed tokens that calls are using before they return with updated rate limit data.
    private(set) var borrowedTokens: Int
    
    /// The date when the rate-limiting window will reset.
    private(set) var resetDate: Date
    
    private var currentDate: Date {
        return dateGenerator()
    }
    
    init(rateLimit: Int, dateGenerator: @escaping () -> Date = Date.init) {
        self.dateGenerator = dateGenerator
        self.defaultRateLimit = rateLimit
        
        self.rateLimit = rateLimit
        self.remainingLimit = rateLimit
        self.borrowedTokens = 0
        self.resetDate = Date.distantPast
    }
    
    var hasReachedLimit: Bool {
        return !(remainingLimit - borrowedTokens > 0)
    }
    
    /**
     Tries to borrow a request token from the handler. Cannot borrow a token if the limit is reached
     
     - returns: A boolean indicating if the token was allowed or denied.
     */
    func holdRequestToken() -> Bool {
        guard borrowedTokens < rateLimit else { return false }
        
        if !hasReachedLimit {
            borrowedTokens += 1
            return true
        }
        
        if resetDate < currentDate {
            rateLimit = defaultRateLimit
            remainingLimit = defaultRateLimit
            borrowedTokens += 1
            return true
        }
        return false
    }
    
    /**
     Tries to return a request token to the handler. Cannot return a token if there are no tokens borrowed.
     
     - returns: A boolean indicating if the token was consumed or not.
     */
    @discardableResult
    func consumeRequestToken() -> Bool {
        guard borrowedTokens > 0 else { return false }
        borrowedTokens -= 1
        return true
    }
    
    /**
     Updates the current rate limits with data provided from the response's rate limit headers.
     
     - parameters:
        - newRateLimits: The updated rate limit data provided by the API response.
     */
    func updateRateLimits(_ newRateLimits: RateLimit) {
        rateLimit = newRateLimits.limit
        remainingLimit = newRateLimits.remaining
        resetDate = Date(timeIntervalSinceNow: newRateLimits.resetIntervalInSeconds)
    }
}

