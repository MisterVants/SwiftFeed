//
//  RateLimitParser.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

/// A structure containing rate limit data received from the API.
struct RateLimit {
    
    /// The number of total calls allowed by the current rate limits.
    let limit: Int
    
    /// The updated number of remaining calls allowed to be made.
    let remaining: Int
    
    /// The time interval from now, in seconds, when the remaining rate limit window will be reset.
    let resetIntervalInSeconds: TimeInterval
}

enum RateLimitParser {
    
    enum HeaderKey {
        static let limit = "X-Ratelimit-Limit"
        static let remaining = "X-Ratelimit-Remaining"
        static let resetTime = "X-Ratelimit-Reset"
    }
    
    /**
     Parses the rate limit data provided by the HTTP headers of the API response.
     
     - parameters:
        - httpHeaders: The headers dictionary from the `HTTPURLResponse`.
     - returns: A structure contaning the rate limits data. Returns `nil` if the headers cannot be parsed.
     */
    static func parseRateLimitHeaders(from httpHeaders: [AnyHashable : Any]) -> RateLimit? {
        let rateLimitValue = httpHeaders[HeaderKey.limit] as? String ?? ""
        let rateLimitRemaining = httpHeaders[HeaderKey.remaining] as? String ?? ""
        let rateLimitReset = httpHeaders[HeaderKey.resetTime] as? String ?? ""
        
        guard
            let limit = Int(rateLimitValue),
            let remaining = Int(rateLimitRemaining),
            let resetEpochSeconds = Double(rateLimitReset) else { return nil }
        let resetWindow = resetEpochSeconds - Date().timeIntervalSince1970
        
        return RateLimit(limit: limit, remaining: remaining, resetIntervalInSeconds: resetWindow)
    }
}
